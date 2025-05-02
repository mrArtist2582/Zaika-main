import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/services/database/firestore.dart';
import 'package:food_delivery_app/admin/admin_home.dart';

class ManageOrders extends StatefulWidget {
  const ManageOrders({super.key});

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> _orderStatuses = [
    'Pending',
    'Preparing',
    'Ready for Delivery',
    'Out for Delivery',
    'Delivered',
    'Cancelled'
  ];
  
  final List<String> _paymentStatuses = [
    'Pending',
    'Paid',
    'Failed',
    'Refunded'
  ];

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order status: $e')),
        );
      }
    }
  }
  
  Future<void> _updatePaymentStatus(String orderId, String newStatus) async {
    try {
      await _firestoreService.updatePaymentStatus(orderId, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating payment status: $e')),
        );
      }
    }
  }

  // Get a valid order status value
  String getValidOrderStatus(String? status) {
    if (status != null && _orderStatuses.contains(status)) {
      return status;
    }
    return _orderStatuses.first; // Default to the first status
  }

  // Get a valid payment status value
  String getValidPaymentStatus(String? status) {
    if (status != null && _paymentStatuses.contains(status)) {
      return status;
    }
    return _paymentStatuses.first; // Default to the first status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.receipt_long, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Manage Orders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminHome()));
          },
          tooltip: 'Back to Admin Home',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: () {
              setState(() {
                // Refresh the page
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Orders refreshed')),
              );
            },
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order status filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      'Filter:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...List.generate(
                    _orderStatuses.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: true,
                        label: Text(_orderStatuses[index]),
                        labelStyle: TextStyle(
                          color: _getStatusColor(_orderStatuses[index]),
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: _getStatusColor(_orderStatuses[index]).withOpacity(0.1),
                        onSelected: (bool selected) {
                          // Implement filtering logic here
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getAllOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading orders...'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: Colors.grey[400],
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Orders Found',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'New orders will appear here',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Sort orders by date (newest first)
                  final docs = snapshot.data!.docs;
                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    
                    DateTime aDate;
                    DateTime bDate;
                    
                    if (aData.containsKey('createdAt')) {
                      aDate = (aData['createdAt'] as Timestamp).toDate();
                    } else if (aData.containsKey('date')) {
                      aDate = (aData['date'] as Timestamp).toDate();
                    } else {
                      aDate = DateTime.now();
                    }
                    
                    if (bData.containsKey('createdAt')) {
                      bDate = (bData['createdAt'] as Timestamp).toDate();
                    } else if (bData.containsKey('date')) {
                      bDate = (bData['date'] as Timestamp).toDate();
                    } else {
                      bDate = DateTime.now();
                    }
                    
                    return bDate.compareTo(aDate); // newest first
                  });

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      var orderData = doc.data() as Map<String, dynamic>;

                      // Always get status and payment status regardless of format
                      String status = getValidOrderStatus(orderData['status'] as String?);
                      String paymentStatus = getValidPaymentStatus(orderData['paymentStatus'] as String?);

                      // Check if we're dealing with an old format order or new format
                      bool isOldFormat = !orderData.containsKey('items') && orderData.containsKey('order');

                      // Get the appropriate date
                      DateTime orderDate;
                      if (orderData.containsKey('createdAt')) {
                        orderDate = (orderData['createdAt'] as Timestamp).toDate();
                      } else if (orderData.containsKey('date')) {
                        orderDate = (orderData['date'] as Timestamp).toDate();
                      } else {
                        orderDate = DateTime.now();
                      }
                      
                      // Format the date
                      String formattedDate = DateFormat('MMM dd, yyyy').format(orderDate);
                      String formattedTime = DateFormat('HH:mm').format(orderDate);

                      // Handle old format orders (just receipt and payment method)
                      if (isOldFormat) {
                        String orderText = orderData['order'] ?? "No order details";
                        String paymentMethod = orderData['paymentMethod'] ?? "Unknown";

                        return _buildOrderCard(
                          doc.id, 
                          status, 
                          paymentStatus, 
                          formattedDate,
                          formattedTime,
                          isOldFormat: true,
                          legacyDetails: {
                            'orderText': orderText,
                            'paymentMethod': paymentMethod,
                          },
                        );
                      }

                      // Handle new format orders
                      List<dynamic> items = orderData['items'] ?? [];
                      double total = (orderData['total'] ?? 0.0).toDouble();
                      String paymentMethod = orderData['paymentMethod'] ?? 'Unknown';
                      String deliveryAddress = orderData['deliveryAddress'] ?? 'Not specified';
                      String customerName = orderData['customerName'] ?? 'Unknown';
                      String customerPhone = orderData['customerPhone'] ?? 'Not provided';
                      String rawReceipt = orderData['rawReceipt'] ?? '';

                      return _buildOrderCard(
                        doc.id, 
                        status, 
                        paymentStatus, 
                        formattedDate,
                        formattedTime,
                        isOldFormat: false,
                        orderDetails: {
                          'items': items,
                          'total': total,
                          'paymentMethod': paymentMethod,
                          'deliveryAddress': deliveryAddress,
                          'customerName': customerName,
                          'customerPhone': customerPhone,
                          'rawReceipt': rawReceipt,
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build order card with expansion tile
  Widget _buildOrderCard(
    String orderId, 
    String status, 
    String paymentStatus, 
    String date,
    String time,
    {
      bool isOldFormat = false,
      Map<String, dynamic>? legacyDetails,
      Map<String, dynamic>? orderDetails,
    }
  ) {
    final statusColor = _getStatusColor(status);
    final paymentColor = paymentStatus == 'Paid' 
        ? Colors.green 
        : paymentStatus == 'Failed' 
            ? Colors.red 
            : Colors.orange;
            
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: status == 'Pending' ? Colors.orange.withOpacity(0.5) : Colors.transparent,
          width: status == 'Pending' ? 1.5 : 0,
        ),
      ),
      child: ExpansionTile(
        childrenPadding: EdgeInsets.zero,
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Order #${orderId.substring(0, min(8, orderId.length))}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.payment, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: paymentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      paymentStatus,
                      style: TextStyle(
                        color: paymentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!isOldFormat && orderDetails != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.shopping_bag, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '₹${orderDetails['total'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order details
                if (isOldFormat) _buildLegacyOrderDetails(legacyDetails!, orderId, status, paymentStatus)
                else _buildOrderDetails(orderDetails!, orderId, status, paymentStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Build legacy order details
  Widget _buildLegacyOrderDetails(
    Map<String, dynamic> details,
    String orderId,
    String status,
    String paymentStatus,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Legacy Order Format',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              details['orderText'],
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Method:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                details['paymentMethod'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Order Status Update
          _buildStatusDropdown(orderId, status, false),
          
          const SizedBox(height: 16),
          
          // Payment Status Update
          _buildStatusDropdown(orderId, paymentStatus, true),
        ],
      ),
    );
  }
  
  // Build modern order details
  Widget _buildOrderDetails(
    Map<String, dynamic> details,
    String orderId,
    String status,
    String paymentStatus,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Customer details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Customer Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Name: ${details['customerName']}'),
                Text('Phone: ${details['customerPhone']}'),
                Text('Address: ${details['deliveryAddress']}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Order items
          Row(
            children: [
              const Icon(Icons.shopping_cart, size: 18, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Order Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Items list
          if ((details['items'] as List).isNotEmpty)
            ...List.generate(
              (details['items'] as List).length,
              (index) {
                final item = (details['items'] as List)[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']} x${item['quantity']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (item['selectedAddons'] != null && (item['selectedAddons'] as List).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add-ons:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              ...List.generate(
                                (item['selectedAddons'] as List).length,
                                (addonIndex) {
                                  final addon = (item['selectedAddons'] as List)[addonIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8, top: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '+ ${addon['name']}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          '₹${addon['price'].toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Order items not available in structured format'),
            ),
            
          const SizedBox(height: 12),
          
          // Raw receipt if available
          if (details['rawReceipt'].isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.receipt, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Receipt',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                details['rawReceipt'],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
            
          const Divider(),
          
          // Order summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '₹${details['total'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                details['paymentMethod'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Order Status Update
          _buildStatusDropdown(orderId, status, false),
          
          const SizedBox(height: 16),
          
          // Payment Status Update
          _buildStatusDropdown(orderId, paymentStatus, true),
        ],
      ),
    );
  }
  
  // Build status dropdown
  Widget _buildStatusDropdown(String orderId, String currentStatus, bool isPayment) {
    final List<String> statuses = isPayment ? _paymentStatuses : _orderStatuses;
    final String label = isPayment ? 'Update Payment Status' : 'Update Order Status';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPayment ? Colors.purple : Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPayment 
                ? Colors.purple.withOpacity(0.5) 
                : Colors.blue.withOpacity(0.5),
            ),
            color: isPayment 
              ? Colors.purple.withOpacity(0.05) 
              : Colors.blue.withOpacity(0.05),
          ),
          child: DropdownButtonFormField<String>(
            value: currentStatus,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              prefixIcon: Icon(
                isPayment ? Icons.payment : Icons.local_shipping,
                color: isPayment ? Colors.purple : Colors.blue,
              ),
            ),
            items: statuses
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                if (isPayment) {
                  _updatePaymentStatus(orderId, value);
                } else {
                  _updateOrderStatus(orderId, value);
                }
              }
            },
          ),
        ),
      ],
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
      case 'Paid':
        return Colors.green;
      case 'Failed':
        return Colors.red;
      case 'Refunded':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }
} 