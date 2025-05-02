import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Existing Firestore collection references
  final CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  final CollectionReference contacts = FirebaseFirestore.instance.collection('contacts');

  // Admin document ID (customize if needed)
  final String adminDocId = 'default_admin';

  // ------------------ Existing Features ------------------

  // Save order to database
  Future<void> saveOrderToDatabase(String receipt, String paymentMethod) async {
    // Parse the receipt to extract items, total amount, etc.
    List<Map<String, dynamic>> items = [];
    double total = 0.0;
    String deliveryAddress = "Not specified";
    
    // Process receipt to extract necessary data
    final receiptLines = receipt.split('\n');
    for (var line in receiptLines) {
      // Extract delivery address
      if (line.contains("Delivered To :")) {
        deliveryAddress = line.split("Delivered To :").last.trim();
        continue;
      }
      
      // Extract total amount
      if (line.contains("Final Amount")) {
        try {
          final priceString = line.split(":").last.trim();
          // Remove 'Rs.' prefix and convert to double
          total = double.parse(priceString.replaceAll("Rs.", "").trim());
        } catch (e) {
          if (kDebugMode) {
            print("Error parsing total: $e");
          }
        }
        continue;
      }
      
      // Extract items (lines with "x" that indicate quantity)
      if (line.contains(" x ") && line.contains(" - ")) {
        try {
          final parts = line.split(" - ");
          final itemPart = parts[0].trim();
          final pricePart = parts[1].trim();
          
          final quantityParts = itemPart.split(" x ");
          final quantity = int.parse(quantityParts[0].trim());
          final name = quantityParts[1].trim();
          
          // Extract price (remove "Rs." and convert to double)
          final price = double.parse(pricePart.replaceAll("Rs.", "").trim()) / quantity;
          
          items.add({
            'name': name,
            'price': price,
            'quantity': quantity,
            'selectedAddons': [] // Default empty addons
          });
        } catch (e) {
          if (kDebugMode) {
            print("Error parsing item: $e");
          }
        }
      }
      
      // Extract add-ons
      if (line.contains("Add-ons") && items.isNotEmpty) {
        try {
          final addonsString = line.split(":").last.trim();
          final addonsList = addonsString.split(", ");
          
          final itemAddons = [];
          for (var addon in addonsList) {
            final addonName = addon.split(" (Rs.")[0].trim();
            final addonPrice = double.parse(addon.split(" (Rs.")[1].split(")")[0].trim());
            
            itemAddons.add({
              'name': addonName,
              'price': addonPrice
            });
          }
          
          // Add these addons to the last item
          if (items.isNotEmpty) {
            items.last['selectedAddons'] = itemAddons;
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error parsing addons: $e");
          }
        }
      }
    }

    // Save to Firestore with all required fields
    await orders.add({
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'Pending',
      'paymentStatus': 'Paid',
      'paymentMethod': paymentMethod,
      'total': total,
      'items': items,
      'deliveryAddress': deliveryAddress,
      'customerName': 'Customer', // Default value
      'customerPhone': 'Not provided', // Default value
      'rawReceipt': receipt, // Store the original receipt for reference
    });
  }

  // Save contact form data to Firestore
  Future<void> saveContactForm(String name, String email, String contact, String description) async {
    await contacts.add({
      'name': name,
      'email': email,
      'contact': contact,
      'description': description,
      'timestamp': Timestamp.now(),
    });
  }

  // ------------------ Admin Order Management Feature ------------------
  
  // Get a stream of all orders from Firestore
  Stream<QuerySnapshot> getAllOrders() {
    // Simply get all orders without ordering by a specific field
    return orders.snapshots();
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    // First, get the order document to check its format
    DocumentSnapshot orderDoc = await orders.doc(orderId).get();
    Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
    
    // Check if it's an old format order
    bool isOldFormat = !orderData.containsKey('status');
    
    if (isOldFormat) {
      // For old format, add new fields instead of just updating status
      await orders.doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'paymentStatus': 'Paid', // Default to paid for older orders
        // Add other needed fields with defaults to make it compatible with new format
        'customerName': 'Customer',
        'customerPhone': 'Not provided',
        'deliveryAddress': 'Not specified'
      });
    } else {
      // For new format, just update status
      await orders.doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(String orderId, String newPaymentStatus) async {
    // First, get the order document to check its format
    DocumentSnapshot orderDoc = await orders.doc(orderId).get();
    Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
    
    // Check if it's an old format order
    bool isOldFormat = !orderData.containsKey('paymentStatus');
    
    if (isOldFormat) {
      // For old format, add new fields
      await orders.doc(orderId).update({
        'paymentStatus': newPaymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        // Add status if it doesn't exist
        'status': orderData['status'] ?? 'Pending',
        // Add other needed fields with defaults to make it compatible with new format
        'customerName': 'Customer',
        'customerPhone': 'Not provided',
        'deliveryAddress': 'Not specified'
      });
    } else {
      // For new format, just update payment status
      await orders.doc(orderId).update({
        'paymentStatus': newPaymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update full order with multiple fields
  Future<void> updateFullOrder(String orderId, Map<String, dynamic> updates) async {
    // Add updatedAt timestamp
    updates['updatedAt'] = FieldValue.serverTimestamp();
    
    // Update the document
    await orders.doc(orderId).update(updates);
  }

  // ------------------ New Food Management Features ------------------

  // Add a new food item to "added_foods" subcollection
  Future<void> addFood({
    required String name,
    required String description,
    required double price,
    required String category,
    required String imageUrl, // Direct image URL
    required List<Map<String, dynamic>> addons,
  }) async {
    await _db
        .collection('admin')
        .doc(adminDocId)
        .collection('added_foods')
        .add({
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'addons': addons,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Update a food item in "manage_foods" (or any subcollection)
  Future<void> updateFood({
    required String subcollection,
    required String docId,
    required Map<String, dynamic> updatedData,
  }) async {
    await _db
        .collection('admin')
        .doc(adminDocId)
        .collection(subcollection)
        .doc(docId)
        .update(updatedData);
  }

  // Delete a food item from a given subcollection
  Future<void> deleteFood({
    required String subcollection,
    required String docId,
  }) async {
    await _db
        .collection('admin')
        .doc(adminDocId)
        .collection(subcollection)
        .doc(docId)
        .delete();
  }

  // Get a stream of food items from a given subcollection
  Stream<List<Map<String, dynamic>>> getFoods(String subcollection) {
    return _db
        .collection('admin')
        .doc(adminDocId)
        .collection(subcollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            // ignore: unnecessary_cast
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}
