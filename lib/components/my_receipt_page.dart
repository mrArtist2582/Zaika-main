import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

import 'package:food_delivery_app/components/my_button.dart';
import 'package:food_delivery_app/models/restauarant.dart';
import 'package:food_delivery_app/pages/home_page.dart';

class MyReceiptPage extends StatelessWidget {
  final String paymentMethod;
  final String receipt;

  const MyReceiptPage({
    super.key,
    required this.paymentMethod,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    DateTime estimatedTime = DateTime.now().add(const Duration(minutes: 25));
    String formattedTime =
        "${estimatedTime.hour}:${estimatedTime.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Thank you for your Order!",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                    IconButton(
                  onPressed: () async {
                    await _generateInvoice(context, receipt, paymentMethod);
                  },
                  icon: Icon(Icons.download)),
                ],
              ), 
              const SizedBox(height: 25),
              Text(
                "Estimated delivery time: $formattedTime",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              // Receipt Container
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  
                   
                    const SizedBox(height: 10),

                    // Payment Method inside the container
                    Text(
                      "Payment Method: ${paymentMethod.isNotEmpty ? paymentMethod : "Not Provided"}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Close Button
              MyButton(
                onTap: () {
                  // Clear the cart before navigating to HomePage
                  Provider.of<Restauarant>(context, listen: false).clearCart();

                  // Navigate to HomePage and remove previous pages from stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                text: "Close",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to check permission and save invoice PDF
Future<void> _generateInvoice(
    BuildContext context, String receipt, String paymentMethod) async {
  try {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year}";

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("Zaika", style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                    pw.Text("Food Delivery Invoice", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Text("Invoice Date: $formattedDate", style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.SizedBox(height: 15),
              pw.Text("Order Summary", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              ...receipt.split("\n").where((line) => line.contains(" - ")).map((line) {
                final parts = line.split(" - ");
                final itemName = parts[0];
                final itemPrice = parts.length > 1 ? parts[1] : "";
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(itemName, style: pw.TextStyle(fontSize: 14)),
                    pw.Text(itemPrice, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                );
              }),
              pw.SizedBox(height: 10),
              pw.Text("Summary", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              ...receipt.split("\n").where((line) =>
                line.contains("Total Items") ||
                line.contains("Total Price") ||
                line.contains("GST") ||
                line.contains("Delivery Fee") ||
                line.contains("Final Amount")).map((line) {
                final parts = line.split(":");
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(parts[0].trim(), style: pw.TextStyle(fontSize: 14)),
                    pw.Text(parts.length > 1 ? parts[1].trim() : "", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                );
              }),
              pw.SizedBox(height: 15),
              pw.Text("Payment Method: ${paymentMethod.isNotEmpty ? paymentMethod : "Not Provided"}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
              pw.SizedBox(height: 15),
              if (receipt.contains("Delivered To"))
                pw.Text("Delivered To: ${receipt.split("Delivered To : ").last}", style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.SizedBox(height: 25),
              pw.Center(child: pw.Text("Thank you for ordering with Zaika!", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green700))),
            ],
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    if (kIsWeb) {
      // On web, just show a notification that this feature is web-only
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PDF download is only available in the web version"),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      // Mobile or desktop logic
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = "${directory.path}/invoice_${now.millisecondsSinceEpoch}.pdf";
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      _showInvoiceDialog(context, filePath);
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error generating invoice: $e");
    }
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to generate invoice: ${e.toString()}"),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _showInvoiceDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Invoice Generated"),
          content: const Text("Your invoice has been generated successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                OpenFile.open(filePath);
              },
              child: const Text("Open"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
