import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:food_delivery_app/pages/about_us.dart';
import 'package:food_delivery_app/pages/contact.dart';
import 'package:food_delivery_app/services/auth/login_or_register.dart';
import 'package:food_delivery_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/admin/admin_login.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Dark Mode Toggle
          GestureDetector(
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(13),
              ),
              margin: const EdgeInsets.only(top: 10, left: 25, right: 25),
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.moon_stars,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ],
              ),
            ),
          ),

          // Admin Login Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminLogin()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(13),
              ),
              margin: const EdgeInsets.only(top: 10, left: 25, right: 25),
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Admin Panel",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  Icon(
                    Icons.admin_panel_settings,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ],
              ),
            ),
          ),

          // About Us Container
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUs()),
              );
            },
            child: settingsContainer(context, "About Us"),
          ),

          // Contact Container
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Contact()),
              );
            },
            child: settingsContainer(context, "Contact"),
          ),
          // Inside SettingsPage's Column widget
        
          // Logout Container
          GestureDetector(
            onTap: () async {
              try {
                // Log out from Firebase
                await FirebaseAuth.instance.signOut();

                // Navigate to the LoginOrRegister widget, removing all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginOrRegister(),
                  ),
                  (route) => false,
                );
              } catch (e) {
                // Handle errors
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error logging out: $e")),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(13),
              ),
              margin: const EdgeInsets.only(top: 10, left: 25, right: 25),
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget settingsContainer(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(13),
      ),
      margin: const EdgeInsets.only(top: 10, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
