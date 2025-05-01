import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/my_button.dart';
import 'package:food_delivery_app/components/my_cart_tile.dart';
import 'package:food_delivery_app/models/restauarant.dart';
import 'package:food_delivery_app/pages/delivery_progress_page.dart';
import 'package:food_delivery_app/pages/home_page.dart';
import 'package:food_delivery_app/services/noti_service/noti_service.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Only used if kIsWeb

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Restauarant>(builder: (context, restaurant, child) {
      final userCart = restaurant.cart;
      double totalPrice =
          userCart.fold(0, (sum, cartItem) => sum + cartItem.totalPrice);

      return Scaffold(
        appBar: AppBar(
          title: const Text("Cart"),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title:
                        const Text("Are you sure You want to clear the Cart?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          restaurant.clearCart();
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete),
            ),
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: userCart.isEmpty
                  ? const Center(
                      child: Text(
                        "Cart is empty..",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: userCart.length,
                      itemBuilder: (context, index) {
                        final cartItem = userCart[index];
                        return MyCartTile(cartItem: cartItem);
                      },
                    ),
            ),
            totalPrice > 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Total Price : Rs ${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : SizedBox(),
            MyButton(
              onTap: () {
                if (userCart.isEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Notice"),
                        content: const Text("First order something."),
                        actions: [],
                      );
                    },
                  );

                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  });
                } else {
                  _showPaymentDialog(
                      context, totalPrice, restaurant.deliveryAddress);
                }
              },
              text: "Go to checkout",
            ),
            const SizedBox(height: 25),
          ],
        ),
      );
    });
  }

  void _showPaymentDialog(
      BuildContext context, double totalPrice, String deliveryAddress) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: Color.fromARGB(255, 233, 174, 91),
          ),
        ),
        child: AlertDialog(
          title: const Text("Select Payment Method",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Cash on Delivery",
                    style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.money, color: Colors.black),
                onTap: () {
                  Navigator.pop(context);
                  showLottieAnimation(context, "Cash on Delivery");
                },
              ),
              ListTile(
                title: const Text("Payment Gateway",
                    style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.credit_card, color: Colors.black),
                onTap: () {
                  Navigator.pop(context);
                  startPayment(totalPrice, deliveryAddress);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

void startPayment(double amount, String deliveryAddress) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userContact = prefs.getString('contact') ?? "9904225520";
  String userEmail = prefs.getString('email') ?? "kashishdarji25@example.com";

  // Mobile platform
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    var options = {
      'key': 'rzp_test_NHBdhCepaAeqho',
      'amount': (amount * 100).toInt(),
      'name': 'Zaika',
      'description': 'Food Order Payment',
      'timeout': 120,
      'prefill': {
        'contact': userContact,
        'email': userEmail,
      },
      'notes': {
        'Delivery Address': deliveryAddress,
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      // Fluttertoast.showToast(msg: "Payment failed: ${e.toString()}");
    }
  }

  // Web platform
  else if (kIsWeb) {
    _startWebPayment(amount, userEmail, userContact, deliveryAddress);
  } else {
    // Fallback for Windows/Linux/Mac if needed
    if (kDebugMode) print("Platform not supported for payment.");
  }
}
 void _startWebPayment(double amount, String email, String contact, String address) {
  final options = '''
    {
      "key": "rzp_test_NHBdhCepaAeqho",
      "amount": "${(amount * 100).toInt()}",
      "currency": "INR",
      "name": "Zaika",
      "description": "Food Order Payment",
      "handler": function (response){
        window.dispatchEvent(new CustomEvent("payment.success", { detail: response }));
      },
      "prefill": {
        "email": "$email",
        "contact": "$contact"
      },
      "notes": {
        "Delivery Address": "$address"
      },
      "theme": {
        "color": "#F37254"
      }
    }
  ''';

  final razorpayScript = html.ScriptElement()
    ..src = 'https://checkout.razorpay.com/v1/checkout.js'
    ..type = 'text/javascript'
    ..defer = true;

  razorpayScript.onLoad.listen((event) {
    html.Element checkout = html.document.createElement('script');
    checkout.setAttribute('type', 'text/javascript');
    checkout.innerHtml = '''
      var rzp = new Razorpay($options);
      rzp.open();
    ''';
    html.document.body!.append(checkout);
  });

  html.document.body!.append(razorpayScript);

  // Listener for success
  html.window.addEventListener("payment.success", (event) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryProgressPage(paymentMethod: "RazorPay (Web)"),
      ),
    );
    NotiService().showNotification(title: "Zaika", body: "Your Order has been Placed!");
  });
}

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Fluttertoast.showToast(msg: "Payment Success: ${response.paymentId}");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryProgressPage(paymentMethod: "RazorPay"),
      ),
    );
    NotiService()
        .showNotification(title: "Zaika", body: "Your Order has been Placed!");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
  }

  void showLottieAnimation(BuildContext context, String paymentMethod) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/deli.json',
              width: 400,
              height: 400,
              repeat: false,
              animate: true,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DeliveryProgressPage(paymentMethod: paymentMethod),
                    ),
                  );
                  NotiService().showNotification(
                      title: "Zaika", body: "Your Order has been Placed!");
                });
              },
            ),
            const SizedBox(height: 10),
            const Text("Processing your payment...",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      razorpay.clear();
    } catch (e) {
      if (kDebugMode) print("Error clearing Razorpay: $e");
    }
    super.dispose();
  }
  
}
