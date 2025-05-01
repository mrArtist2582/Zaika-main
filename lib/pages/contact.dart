import 'package:flutter/material.dart';
import 'package:food_delivery_app/services/database/firestore.dart' show FirestoreService;
import 'package:lottie/lottie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Save data using FirestoreService
      await _firestoreService.saveContactForm(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _descriptionController.text,
      );

      // Show Lottie animation after submission
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pop(context); // Close animation

            // Ensure _isSubmitting is reset and navigate to home
            setState(() {
              _isSubmitting = false;
            });

            // Navigate to Home page (adjust route if needed)
            Navigator.popUntil(context, (route) => route.isFirst);
          });
          return Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/submitted.json',
                      repeat: false, height: 400, width: 400),
                  SizedBox(height: 10),
                  Text(
                    "Submission Successful!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Clear input fields
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check for web or mobile platform
    final isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: Text("Contact",
            style: TextStyle(
                color: Color.fromRGBO(66, 66, 66, 1),
                fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 32.0 : 16.0), // Larger padding for web
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("Name", _nameController),
                _buildTextField("Email", _emailController, email: true),
                _buildTextField("Contact Number", _phoneController, phone: true),
                _buildTextField("Description", _descriptionController, maxLines: 4),
                SizedBox(height: isWeb ? 30 : 20), // Larger gap on web
                Center(
                  child: GestureDetector(
                    onTap: _isSubmitting ? null : _submitForm,
                    child: Container(
                      width: isWeb ? 400 : double.infinity, // Fixed width for web
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _isSubmitting ? Colors.grey : Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Submit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function for text fields
  Widget _buildTextField(String label, TextEditingController controller,
      {bool email = false, bool phone = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: email
            ? TextInputType.emailAddress
            : phone
                ? TextInputType.phone
                : TextInputType.text,
        maxLines: maxLines,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $label";
          }
          if (email &&
              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value)) {
            return "Enter a valid email";
          }
          if (phone && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
            return "Enter a valid 10-digit phone number";
          }
          return null;
        },
      ),
    );
  }
}
