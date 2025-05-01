import 'package:cloud_firestore/cloud_firestore.dart';

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
    await orders.add({
      'date': DateTime.now(),
      'order': receipt,
      'paymentMethod': paymentMethod,
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
