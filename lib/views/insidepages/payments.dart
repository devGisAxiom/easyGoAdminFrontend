import 'package:flutter/material.dart';
import 'package:getbike_admin/utils/utilities.dart';

class PaymentList extends StatelessWidget {
  final List<Map<String, dynamic>> paymentData = [
    {
      'userId': 'U001',
      'username': 'John Doe',
      'bikeName': 'Royal Enfield',
      'noOfDays': '5',
      'pickupLoc': 'Location A',
      'dropLoc': 'Location B',
      'bookingId': 'B001',
      'payment': '₹7500',
      'paymentStatus': 'Paid',
    },
    {
      'userId': 'U002',
      'username': 'Jane Smith',
      'bikeName': 'Yamaha R15',
      'noOfDays': '3',
      'pickupLoc': 'Location C',
      'dropLoc': 'Location D',
      'bookingId': 'B002',
      'payment': '₹3600',
      'paymentStatus': 'Pending',
    },
    {
      'userId': 'U003',
      'username': 'Mike Johnson',
      'bikeName': 'KTM Duke',
      'noOfDays': '7',
      'pickupLoc': 'Location E',
      'dropLoc': 'Location F',
      'bookingId': 'B003',
      'payment': '₹10500',
      'paymentStatus': 'Failed',
    },
  ];

  void _showCallCustomerDialog(BuildContext context, String username, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call $username'),
        content: Text('Do you want to call the customer with User ID: $userId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $username...')),
              );
            },
            child: Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, String bookingId) {
    String selectedStatus = 'Paid';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Update Payment Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Paid', 'Pending', 'Failed'].map((status) {
              return RadioListTile<String>(
                title: Text(status),
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking $bookingId updated to $selectedStatus')),
                );
              },
              child: Text('Update', style: smalltextwhite,),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment List', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('User ID')),
              DataColumn(label: Text('Username')),
              DataColumn(label: Text('Bike Name')),
              DataColumn(label: Text('No. of Days')),
              DataColumn(label: Text('Pickup Location')),
              DataColumn(label: Text('Drop Location')),
              DataColumn(label: Text('Booking ID')),
              DataColumn(label: Text('Payment')),
              DataColumn(label: Text('Payment Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: paymentData.map((payment) {
              Color statusColor = Colors.green;
              if (payment['paymentStatus'] == 'Pending') {
                statusColor = Colors.orange;
              } else if (payment['paymentStatus'] == 'Failed') {
                statusColor = Colors.red;
              }

              return DataRow(cells: [
                DataCell(Text(payment['userId'])),
                DataCell(Text(payment['username'])),
                DataCell(Text(payment['bikeName'])),
                DataCell(Text(payment['noOfDays'])),
                DataCell(Text(payment['pickupLoc'])),
                DataCell(Text(payment['dropLoc'])),
                DataCell(Text(payment['bookingId'])),
                DataCell(Text(payment['payment'])),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      payment['paymentStatus'],
                      style: TextStyle(color: statusColor),
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showCallCustomerDialog(context, payment['username'], payment['userId']);
                          },
                          child: const Text('Call Customer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {
                            _showUpdateStatusDialog(context, payment['bookingId']);
                          },
                          child: const Text('Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
             void _showAlert(BuildContext context ,String name , String phonenumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Confirmation"),
          content: const Text("Are you sure you want to continue?"),
      
        );
      },
    );
  }
}
