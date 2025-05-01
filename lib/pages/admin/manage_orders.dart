import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:food_delivery_app/models/food.dart';

class ManageOrders extends StatefulWidget {
  const ManageOrders({super.key});

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _orderStatuses = [
    'Pending',
    'Preparing',
    'Ready for Delivery',
    'Out for Delivery',
    'Delivered',
    'Cancelled'
  ];

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Manage Orders',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var orderData = doc.data() as Map<String, dynamic>;
                    var items = orderData['items'] as List<dynamic>;
                    var total = orderData['total'] ?? 0.0;
                    var status = orderData['status'] ?? 'Pending';
                    var createdAt = (orderData['createdAt'] as Timestamp).toDate();
                    var paymentStatus = orderData['paymentStatus'] ?? 'Pending';
                    var paymentMethod = orderData['paymentMethod'] ?? 'Unknown';
                    var deliveryAddress = orderData['deliveryAddress'] ?? 'Not specified';
                    var customerName = orderData['customerName'] ?? 'Unknown';
                    var customerPhone = orderData['customerPhone'] ?? 'Not provided';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text('Order #${doc.id.substring(0, 8)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(createdAt)}',
                            ),
                            Text(
                              'Payment: $paymentStatus',
                              style: TextStyle(
                                color: paymentStatus == 'Paid' ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Customer Details:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('Name: $customerName'),
                                Text('Phone: $customerPhone'),
                                Text('Address: $deliveryAddress'),
                                const Divider(),
                                const Text(
                                  'Order Items:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item['name']} x${item['quantity']}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          if (item['selectedAddons'] != null)
                                            ...(item['selectedAddons'] as List<dynamic>)
                                                .map((addon) => Padding(
                                                      padding: const EdgeInsets.only(left: 16),
                                                      child: Text('+ ${addon['name']}'),
                                                    )),
                                          Text(
                                            '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    )),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Subtotal:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '\$${total.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Payment Method:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      paymentMethod,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: status,
                                  decoration: const InputDecoration(
                                    labelText: 'Update Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _orderStatuses
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      _updateOrderStatus(doc.id, value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Ready for Delivery':
        return Colors.purple;
      case 'Out for Delivery':
        return Colors.indigo;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 