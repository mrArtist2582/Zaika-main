import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_button.dart' show MyButton;
import 'package:food_delivery_app/models/restauarant.dart';
import 'package:food_delivery_app/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// For kIsWeb

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "", email = "", contact = "", address = "";
  String selectedAvatar = "assets/avatars/avatar1.png";

  List<String> avatarList = [
    "assets/avatars/avatar1.png",
    "assets/avatars/avatar2.png",
    "assets/avatars/avatar3.png",
    "assets/avatars/avatar4.png",
    "assets/avatars/avatar5.png",
  ];

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "Guest";
      email = prefs.getString('email') ?? "Not Set";
      contact = prefs.getString('contact') ?? "Not Set";
      address = prefs.getString('address') ?? "Not Set";
      selectedAvatar = prefs.getString('avatar') ?? avatarList[0];
    });
  }

  Future<void> _updateProfile(String newUsername, String newEmail,
      String newContact, String newAddress, String newAvatar) async {
    if (newUsername.isEmpty ||
        newEmail.isEmpty ||
        newContact.isEmpty ||
        newAddress.isEmpty) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    await prefs.setString('email', newEmail);
    await prefs.setString('contact', newContact);
    await prefs.setString('address', newAddress);
    await prefs.setString('avatar', newAvatar);

    setState(() {
      username = newUsername;
      email = newEmail;
      contact = newContact;
      address = newAddress;
      selectedAvatar = newAvatar;
    });

    Navigator.pop(context);
    _showUpdateDialog();
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Profile Updated"),
          content: const Text(
              "Your profile details have been successfully updated."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and check if it's a web platform
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: screenWidth > 600 ? 80 : 50, // Adjust size based on screen width
                  backgroundImage: AssetImage(selectedAvatar)),
              const SizedBox(height: 20),
              _buildProfileContainer("Username", username),
              _buildProfileContainer("Email", email),
              _buildProfileContainer("Contact", contact),
              _buildProfileContainer("Address", address),
              const SizedBox(height: 20),
              _buildEditButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContainer(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
        width: double.infinity,
        child: MyButton(onTap: _showEditProfileSheet, text: "Edit Profile"));
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              TextEditingController usernameController =
                  TextEditingController(text: username);
              TextEditingController emailController =
                  TextEditingController(text: email);
              TextEditingController contactController =
                  TextEditingController(text: contact);
              TextEditingController addressController =
                  TextEditingController(text: address);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField("Username", usernameController),
                    _buildTextField("Email", emailController),
                    _buildTextField("Contact", contactController),
                    _buildTextField("Address", addressController),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: avatarList.map((avatar) {
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedAvatar = avatar),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(avatar),
                            radius: 30,
                            child: selectedAvatar == avatar
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: double.infinity,
                        child: MyButton(
                            onTap: () {
                              _updateProfile(
                                usernameController.text,
                                emailController.text,
                                contactController.text,
                                addressController.text,
                                selectedAvatar,
                              );
                              context.read<Restauarant>().updateDeliveryAddress(
                                  addressController.text);
                            },
                            text: "Save Changes")),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
