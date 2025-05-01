import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:food_delivery_app/models/cart_item.dart';

import 'food.dart';

class Restauarant extends ChangeNotifier {
  // Key for storing custom menu items in SharedPreferences
  // ignore: constant_identifier_names
  static const String CUSTOM_MENU_KEY = 'custom_menu_items';
  
  //list of food menu (default items)
  final List<Food> _defaultMenu = [
// burgers

    //VEG burger
    Food(
      name: "Veg Burger", 
      description:
          "A wholesome and flavorful vegetarian burger featuring a crisp veggie patty made from fresh vegetables.",
      imagePath: "lib/images/Burger/veg_burger.png",
      price: 89,
      catagory: FoodCatagory.bugers,
      availableAddons: [
        Addon(price: 20, name: "Extra Avocado"),
        Addon(price: 30, name: "Grilled Tofu"),
        Addon(price: 35, name: "Pickled Cucumbers"),
      ],
    ),


    // Classic cheese burger
    Food(
      name: "Classic Burger",
      description: "A juicy beef patty topped with melted cheddar cheese, "
          "fresh lettuce, tomatoes.",
      imagePath: "lib/images/Burger/cheese_burger.png",
      price: 120,
      catagory: FoodCatagory.bugers,
      availableAddons: [
        Addon(price: 20, name: "Extra Cheese"),
        Addon(price: 30, name: "Jalapenos"),
        Addon(price: 35, name: "Avocado"),
      ],
    ),

    // Aloha burger
    Food(
      name: "Aloha Burger",
      description:
          "A delicious burger featuring a grilled beef patty topped with melted Swiss cheese.",
      imagePath: "lib/images/Burger/aloha_burger.png",
      price: 130,
      catagory: FoodCatagory.bugers,
      availableAddons: [
        Addon(price: 20, name: "Extra Pineapple"),
        Addon(price: 30, name: "Grilled Onions"),
        Addon(price: 35, name: "Avocado"),
      ],
    ),

    // BBq burger
    Food(
      name: "BBQ Burger",
      description:
          "A mouthwatering burger featuring a juicy beef patty smothered in smoky barbecue sauce.",
      imagePath: "lib/images/Burger/bbq_burger.png",
      price: 140,
      catagory: FoodCatagory.bugers,
      availableAddons: [
        Addon(price: 20, name: "Extra Bacon"),
        Addon(price: 30, name: "Extra BBQ Sauce"),
        Addon(price: 35, name: "Pickles"),
      ],
    ),

    // Blue moon burger
    Food(
      name: "Blue Moon Burger",
      description:
          "A unique and delicious burger with a savory beef patty, tangy blue cheese.",
      imagePath: "lib/images/Burger/blueMoon_buger.png",
      price: 150,
      catagory: FoodCatagory.bugers,
      availableAddons: [
        Addon(price: 20, name: "Extra Blue Cheese"),
        Addon(price: 30, name: "Grilled Mushrooms"),
        Addon(price: 35, name: "Caramelized Onions"),
      ],
    ),

// salads
    // Asiansesame salad
    Food(
      name: "Asiansesame salad",
      description:
          "A refreshing salad with a mix of crisp greens, crunchy carrots.",
      imagePath: "lib/images/Salad/Asiansesame_salad.jpg",
      price: 100,
      catagory: FoodCatagory.salads,
      availableAddons: [
        Addon(price: 20, name: "Crispy Noodles"),
        Addon(price: 30, name: "Extra Sesame Seeds"),
        Addon(price: 35, name: "Avocado"),
      ],
    ),

    // Caeser salad
    Food(
      name: "Caeser salad",
      description:
          "A classic Caesar salad with crisp romaine lettuce, crunchy croutons. ",
      imagePath: "lib/images/Salad/Caeser_salad.jpeg",
      price: 110,
      catagory: FoodCatagory.salads,
      availableAddons: [
        Addon(price: 20, name: "Bacon Bits"),
        Addon(price: 30, name: "Extra Parmesan"),
        Addon(price: 35, name: "Crispy Onions"),
      ],
    ),

    // Greek Salad
    Food(
      name: "Greek Salad",
      description:
          "A vibrant and healthy salad featuring crisp cucumbers, juicy tomatoes.",
      imagePath: "lib/images/Salad/Greek_salad.jpeg",
      price: 120,
      catagory: FoodCatagory.salads,
      availableAddons: [
        Addon(price: 20, name: "Extra Feta"),
        Addon(price: 30, name: "Bell Peppers"),
        Addon(price: 35, name: "Toasted Nuts"),
      ],
    ),

    // Quinoa Salad
    Food(
      name: "Quinoa Salad",
      description:
          "A nourishing salad made with fluffy quinoa, mixed greens, cherry tomatoes.",
      imagePath: "lib/images/Salad/Quinoa_salad.jpeg",
      price: 130,
      catagory: FoodCatagory.salads,
      availableAddons: [
        Addon(price: 20, name: "Extra Feta"),
        Addon(price: 30, name: "Bell Peppers"),
        Addon(price: 35, name: "Toasted Almonds"),
      ],
    ),

    // South west salad
    Food(
      name: "South West Salad",
      description:
          "A bold and flavorful salad featuring crisp romaine lettuce, black beans.",
      imagePath: "lib/images/Salad/Southwest_salad.jpeg",
      price: 150,
      catagory: FoodCatagory.salads,
      availableAddons: [
        Addon(price: 25, name: "Grilled Chicken"),
        Addon(price: 20, name: "Avocado"),
        Addon(price: 15, name: "Extra Cheese"),
      ],
    ),

// sides

    // Garlic Side
    Food(
      name: "Garlic Bread Side",
      description:
          "A delicious side dish featuring crispy, golden-brown garlic bread slices brushed with herb butter, perfect for complementing any meal.",
      imagePath: "lib/images/Sides/Garlic_sides.jpg",
      price: 100,
      catagory: FoodCatagory.sides,
      availableAddons: [
        Addon(price: 20, name: "Extra Cheese"),
        Addon(price: 15, name: "Chili Flakes"),
        Addon(price: 10, name: "Herb Butter"),
      ],
    ),

    // Loaded fries
    Food(
      name: "Loaded Fries",
      description:
          "A generous portion of crispy golden fries topped with melted cheese.",
      imagePath: "lib/images/Sides/Loaded_fries.jpeg",
      price: 99,
      catagory: FoodCatagory.sides,
      availableAddons: [
        Addon(price: 30, name: "Extra Cheese"),
        Addon(price: 25, name: "Jalapeños"),
        Addon(price: 20, name: "BBQ Sauce"),
      ],
    ),

    // mac side
    Food(
      name: "Mac Side",
      description:
          "A creamy and delicious macaroni and cheese dish made with tender pasta smothered in a rich.",
      imagePath: "lib/images/Sides/mac_sides.jpg",
      price: 110,
      catagory: FoodCatagory.sides,
      availableAddons: [
        Addon(price: 25, name: "Extra Cheese"),
        Addon(price: 30, name: "Bacon Bits"),
        Addon(price: 20, name: "Truffle Oil"),
      ],
    ),

    // onion rings
    Food(
      name: "Onion Rings",
      description:
          "Crispy and golden-brown onion rings coated in a seasoned batter, fried to perfection.",
      imagePath: "lib/images/Sides/Onion_rings.jpeg",
      price: 120,
      catagory: FoodCatagory.sides,
      availableAddons: [
        Addon(price: 15, name: "Extra Dipping Sauce"),
        Addon(price: 20, name: "Cheese Sauce"),
        Addon(price: 25, name: "Spicy Seasoning"),
      ],
    ),

    // sweet potato
    Food(
      name: "Sweet Potato Fries",
      description:
          "Deliciously crispy sweet potato fries, lightly seasoned and served .",
      imagePath: "lib/images/Sides/Sweet_potato_side.jpg",
      price: 130,
      catagory: FoodCatagory.sides,
      availableAddons: [
        Addon(price: 20, name: "Honey Mustard"),
        Addon(price: 25, name: "Cheese Sauce"),
        Addon(price: 15, name: "Cinnamon Sugar"),
      ],
    ),

// pizza

    // Margherita pizza
    Food(
      name: "Margherita Pizza",
      description:
          "A classic Italian pizza featuring a thin crust topped with rich tomato sauce.",
      imagePath: "lib/images/Pizza/Margherita_pizza.jpg",
      price: 150,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 25, name: "Extra Cheese"),
        Addon(price: 30, name: "Fresh Basil"),
        Addon(price: 20, name: "Cherry Tomatoes"),
      ],
    ),

    // pepperoni pizza
    Food(
      name: "Pepperoni Pizza",
      description:
          "A classic pizza topped with zesty tomato sauce, mozzarella cheese, and crispy pepperoni.",
      imagePath: "lib/images/Pizza/Pepproni_pizza.jpg",
      price: 160,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 25, name: "Extra Cheese"),
        Addon(price: 25, name: "Extra Pepperoni"),
        Addon(price: 15, name: "Bell Peppers"),
      ],
    ),

    // Supreme pizza
    Food(
      name: "Supreme Pizza",
      description:
          "A fully loaded pizza with a rich tomato sauce base, generous cheese, pepperoni.",
      imagePath: "lib/images/Pizza/Supreme_pizza.jpg",
      price: 180,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 20, name: "Extra Mushroom"),
        Addon(price: 20, name: "Extra Olives"),
        Addon(price: 25, name: "Extra Meat"),
      ],
    ),

    // Vagetian pizza
    Food(
      name: "Veggie Pizza",
      description:
          "A delicious and colorful vegetarian pizza loaded with seasonal vegetables.",
      imagePath: "lib/images/Pizza/Vegetable_pizza.jpg",
      price: 170,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 20, name: "Extra Cheese"),
        Addon(price: 15, name: "Bell Peppers"),
        Addon(price: 15, name: "Corn"),
      ],
    ),

    // White Sauce pizza
    Food(
      name: "White Sauce Pizza",
      description:
          "A gourmet pizza made with creamy white garlic sauce instead of traditional tomato sauce.",
      imagePath: "lib/images/Pizza/White_pizza.jpg",
      price: 190,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 25, name: "Extra Cheese"),
        Addon(price: 30, name: "Sliced Garlic"),
        Addon(price: 35, name: "Arugula"),
      ],
    ),

// desserts

    // CHOCO
    Food(
      name: "Chocolate Brownie",
      description:
          "A rich and fudgy chocolate brownie, served warm with a scoop of vanilla ice cream.",
      imagePath: "lib/images/Desserts/Choco_brownie.jpeg",
      price: 120,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Extra Ice Cream"),
        Addon(price: 15, name: "Chocolate Sauce"),
        Addon(price: 10, name: "Nuts"),
      ],
    ),

    // cookie
    Food(
      name: "Chocolate Chip Cookie",
      description:
          "A large, freshly baked chocolate chip cookie with a soft center and crisp edges.",
      imagePath: "lib/images/Desserts/Cookie.jpeg",
      price: 80,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Ice Cream Scoop"),
        Addon(price: 10, name: "Caramel Drizzle"),
        Addon(price: 10, name: "Whipped Cream"),
      ],
    ),

    // ICE
    Food(
      name: "Ice Cream Sundae",
      description:
          "Three scoops of premium ice cream topped with chocolate sauce, whipped cream, and a cherry.",
      imagePath: "lib/images/Desserts/Ice_cream.jpeg",
      price: 100,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Extra Scoop"),
        Addon(price: 10, name: "Hot Fudge"),
        Addon(price: 15, name: "Brownie Pieces"),
      ],
    ),

    // Molten
    Food(
      name: "Molten Lava Cake",
      description:
          "A warm chocolate cake with a gooey, molten chocolate center, served with vanilla ice cream.",
      imagePath: "lib/images/Desserts/Molten_lava_cake.jpg",
      price: 140,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Extra Ice Cream"),
        Addon(price: 10, name: "Raspberry Sauce"),
        Addon(price: 10, name: "Mint Garnish"),
      ],
    ),

    // mousse
    Food(
      name: "Chocolate Mousse",
      description:
          "Light and airy chocolate mousse, topped with whipped cream and chocolate shavings.",
      imagePath: "lib/images/Desserts/Mousse.jpeg",
      price: 110,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Fresh Berries"),
        Addon(price: 10, name: "Chocolate Sauce"),
        Addon(price: 15, name: "Almond Brittle"),
      ],
    ),

    // chocolate milk
    Food(
      name: "Chocolate Milkshake",
      description:
          "A rich and creamy chocolate milkshake topped with whipped cream and chocolate syrup.",
      imagePath: "lib/images/Drinks/Choco_milks.jpeg",
      price: 80,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 10, name: "Extra Chocolate"),
        Addon(price: 15, name: "Cherry Topping"),
        Addon(price: 20, name: "Brownie Pieces"),
      ],
    ),

    // Cranberry
    Food(
      name: "Cranberry Juice",
      description:
          "Refreshing cranberry juice served over ice with a slice of lime.",
      imagePath: "lib/images/Drinks/Cranberry.jpg",
      price: 70,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 10, name: "Extra Lime"),
        Addon(price: 15, name: "Mint Leaves"),
        Addon(price: 10, name: "Soda Splash"),
      ],
    ),

    // fresh lime
    Food(
      name: "Fresh Lime Soda",
      description:
          "A refreshing drink made with fresh lime juice, soda water, and a touch of sugar or salt.",
      imagePath: "lib/images/Drinks/Fresh_lime.jpg",
      price: 60,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 10, name: "Extra Lime"),
        Addon(price: 5, name: "Sugar/Salt Rim"),
        Addon(price: 15, name: "Mint Leaves"),
      ],
    ),

    // orange juice
    Food(
      name: "Fresh Orange Juice",
      description:
          "Freshly squeezed orange juice served over ice for a healthy and refreshing drink.",
      imagePath: "lib/images/Drinks/Orange_juice.jpeg",
      price: 90,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 15, name: "Honey"),
        Addon(price: 10, name: "Mint Garnish"),
        Addon(price: 5, name: "Lemon Slice"),
      ],
    ),

    // virgin mojito

    Food(
      name: "Virgin Mojito",
      description:
          "A refreshing mocktail made with fresh mint leaves, lime juice, sugar syrup, and soda water.",
      imagePath: "lib/images/Drinks/Virgin_mojito.jpeg",
      price: 120,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 15, name: "Extra Mint"),
        Addon(price: 10, name: "Lime Slices"),
        Addon(price: 20, name: "Sugar Syrup"),
      ],
    ),
  ];

  // Combined menu (default + custom items)
  List<Food> _menu = [];
  
  //  user Cart
  final List<CartItem> _cart = [];

  // delivery address
  String _deliveryAddress = '';

  // Constructor - load custom menu items when the model is created
  Restauarant() {
    // Initialize menu with default items before loading custom items
    _menu = List.from(_defaultMenu);
    _loadCustomMenuItems();
  }

  // Load custom menu items from SharedPreferences
  Future<void> _loadCustomMenuItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customMenuJson = prefs.getStringList(CUSTOM_MENU_KEY) ?? [];
      
      final customMenuItems = customMenuJson
          .map((itemJson) => Food.fromMap(json.decode(itemJson)))
          .toList();
      
      // Combine default menu with custom items
      _menu = [..._defaultMenu, ...customMenuItems];
      notifyListeners();
      
      if (kDebugMode) {
        print('Loaded ${customMenuItems.length} custom menu items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading custom menu items: $e');
      }
      // If there's an error, just use the default menu
      _menu = List.from(_defaultMenu);
    }
  }

  // Save custom menu items to SharedPreferences
  Future<void> _saveCustomMenuItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Filter out default menu items to only save custom items
      final customItems = _menu.where((item) => !_isDefaultMenuItem(item)).toList();
      
      final customMenuJson = customItems
          .map((item) => json.encode(item.toMap()))
          .toList();
      
      await prefs.setStringList(CUSTOM_MENU_KEY, customMenuJson);
      
      if (kDebugMode) {
        print('Saved ${customItems.length} custom menu items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving custom menu items: $e');
      }
    }
  }

  // Helper method to check if a food item is from the default menu
  bool _isDefaultMenuItem(Food food) {
    return _defaultMenu.any((defaultItem) => 
      defaultItem.name == food.name && 
      defaultItem.imagePath == food.imagePath);
  }
  
  /*  
          Getter
   */

  List<Food> get menu => _menu;
  List<CartItem> get cart => _cart;
  String get deliveryAddress => _deliveryAddress;
  int get cartItemsCount => _cart.length;

/*  

          Operations
           
          
   */

  // add to cart
  void addToCart(Food food, List<Addon> selectedAddons) {
    // see if there is a cart item  already with  the same food and selected addons
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      // check if the food  items  are  the same
      bool isSameFood = item.food == food;
      // check if the  list of selected addons are the same

      bool isSameAddons =
          ListEquality().equals(item.selectedAddons, selectedAddons);
      return isSameFood && isSameAddons;
    });

    // if item is already exists , increase it's quantity
    if (cartItem != null) {
      cartItem.quantity++;
    }
    // otherwise , add a new cart item to the cart
    else {
      _cart.add(
        CartItem(
          food: food,
          selectedAddons: selectedAddons,
        ),
      );
    }
    notifyListeners();
  }

  // remove from cart

  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);
    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
  }

  // get total price of cart
  double getTotalPrice() {
    double total = 0.0;

    for (CartItem cartItem in _cart) {
      double itemTotal = cartItem.food.price;
      for (Addon addon in cartItem.selectedAddons) {
        itemTotal = itemTotal + addon.price;
      }
      total = total + itemTotal * cartItem.quantity;
    }
    return total;
  }
  // get total number of items in cart

  int getTotalItemCount() {
    int totalItemCount = 0;
    for (CartItem cartItem in _cart) {
      totalItemCount += cartItem.quantity;
    }
    return totalItemCount;
  }

  // clear cart

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // update delivery address

  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress = newAddress;
    notifyListeners();
  }
/*  

          helper

          

   */

  // Generate receipt
  String displayCartReceipt() {
    final receipt = StringBuffer();
    receipt.writeln("Here your Receipt..");
    receipt.writeln();

    // Format the date to include up to seconds only
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    receipt.writeln(formattedDate);
   receipt.writeln();
    for (final cartItem in _cart) {
      receipt.writeln(
          '${cartItem.quantity} x ${cartItem.food.name} - ${_formatPrice(cartItem.food.price)}');
      if (cartItem.selectedAddons.isNotEmpty) {
        receipt
            .writeln("   Add-ons : ${_formateAddons(cartItem.selectedAddons)}");
      }
    }

    // Calculate total price
    double totalPrice = getTotalPrice();
    double gst = totalPrice * 0.05; // 5% GST
    double deliveryCharge = 40.0; // Fixed delivery charge
    double finalAmount = totalPrice + gst + deliveryCharge;

    receipt.writeln("Total Items  :  ${getTotalItemCount()}");
    receipt.writeln("Total Price  :  ${_formatPrice(totalPrice)}");
    receipt.writeln("GST (5%)     :  ${_formatPrice(gst)}");
    receipt.writeln("Delivery Fee :  ${_formatPrice(deliveryCharge)}");
    receipt.writeln("Final Amount :  ${_formatPrice(finalAmount)}");
    receipt.writeln();
    receipt.writeln("Delivered To : $deliveryAddress");

    return receipt.toString();
  }

// Format double value into money
  String _formatPrice(double price) {
    return "Rs.${price.toStringAsFixed(2)}";
  }

// Format a list of addons into a string summary
  String _formateAddons(List<Addon> addons) {
    return addons
        .map((addon) => "${addon.name} (${_formatPrice(addon.price)})")
        .join(", ");
  }

  // Update the add, remove, and update food methods to save changes
  void addFood(Food food) {
    _menu.add(food);
    _saveCustomMenuItems(); // Save changes
    notifyListeners();
  }

  void removeFood(Food food) {
    _menu.remove(food);
    _saveCustomMenuItems(); // Save changes
    notifyListeners();
  }

  void updateFood(Food oldFood, Food newFood) {
    final index = _menu.indexOf(oldFood);
    if (index != -1) {
      _menu[index] = newFood;
      _saveCustomMenuItems(); // Save changes
      notifyListeners();
    }
  }
}
