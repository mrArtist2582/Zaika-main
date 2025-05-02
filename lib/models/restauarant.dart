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
      name: "Asian Sesame Salad",
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

    // Caesar salad
    Food(
      name: "Caesar Salad",
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

    // BBQ Pizza
    Food(
      name: "BBQ Pizza",
      description:
          "A savory pizza with BBQ sauce base, topped with cheese, red onions, and BBQ chicken.",
      imagePath: "lib/images/Pizza/Bbq_pizza.png",
      price: 180,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 20, name: "Extra Chicken"),
        Addon(price: 15, name: "Red Peppers"),
        Addon(price: 25, name: "Extra BBQ Sauce"),
      ],
    ),

    // Chicago pizza
    Food(
      name: "Chicago Pizza",
      description:
          "A deep-dish pizza with a thick crust, loaded with cheese, sauce, and toppings.",
      imagePath: "lib/images/Pizza/Chicago_pizza.png",
      price: 190,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 25, name: "Extra Cheese"),
        Addon(price: 20, name: "Italian Sausage"),
        Addon(price: 15, name: "Green Peppers"),
      ],
    ),

    // Four Cheese pizza
    Food(
      name: "Four Cheese Pizza",
      description:
          "A luxurious pizza topped with a blend of four cheeses: mozzarella, parmesan, gorgonzola, and ricotta.",
      imagePath: "lib/images/Pizza/Four_cheese_pizza_(Quattro _Formaggi) _pizza.png",
      price: 185,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 20, name: "Truffle Oil"),
        Addon(price: 15, name: "Fresh Arugula"),
        Addon(price: 25, name: "Extra Cheese Blend"),
      ],
    ),

    // Veggie Supreme
    Food(
      name: "Veggie Supreme Pizza",
      description:
          "A colorful pizza loaded with fresh vegetables including bell peppers, onions, olives, and mushrooms.",
      imagePath: "lib/images/Pizza/veggie_supreme_pizza.jpg",
      price: 170,
      catagory: FoodCatagory.pizza,
      availableAddons: [
        Addon(price: 20, name: "Extra Cheese"),
        Addon(price: 15, name: "Artichoke Hearts"),
        Addon(price: 15, name: "Sun-dried Tomatoes"),
      ],
    ),

// desserts

    // Cheesecake
    Food(
      name: "Classic Cheesecake",
      description:
          "A rich and creamy cheesecake with a graham cracker crust, topped with fresh berries.",
      imagePath: "lib/images/Desserts/Cheesecake.jpg",
      price: 130,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Berry Compote"),
        Addon(price: 10, name: "Whipped Cream"),
        Addon(price: 20, name: "Chocolate Drizzle"),
      ],
    ),

    // Fruit Tart
    Food(
      name: "Fruit Tart",
      description:
          "A buttery tart shell filled with sweet custard and topped with an assortment of fresh seasonal fruits.",
      imagePath: "lib/images/Desserts/Fruit_tart.jpg",
      price: 120,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Extra Fruits"),
        Addon(price: 10, name: "Whipped Cream"),
        Addon(price: 15, name: "Honey Drizzle"),
      ],
    ),

    // Gulab Jamun
    Food(
      name: "Gulab Jamun",
      description:
          "Soft, spongy milk-solid balls soaked in a rose and cardamom flavored sugar syrup.",
      imagePath: "lib/images/Desserts/Gulab_jamun.jpg",
      price: 100,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Extra Syrup"),
        Addon(price: 20, name: "Vanilla Ice Cream"),
        Addon(price: 10, name: "Pistachio Garnish"),
      ],
    ),

    // Chocolate Lava Cake
    Food(
      name: "Chocolate Lava Cake",
      description:
          "A warm chocolate cake with a gooey, molten chocolate center, served with vanilla ice cream.",
      imagePath: "lib/images/Desserts/Chocolate_lava_cake.jpeg",
      price: 140,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Extra Ice Cream"),
        Addon(price: 10, name: "Raspberry Sauce"),
        Addon(price: 10, name: "Mint Garnish"),
      ],
    ),

    // Tiramisu
    Food(
      name: "Tiramisu",
      description:
          "A classic Italian dessert made of layers of coffee-soaked ladyfingers and mascarpone cream, dusted with cocoa powder.",
      imagePath: "lib/images/Desserts/Tiramisu.jpg",
      price: 150,
      catagory: FoodCatagory.desserts,
      availableAddons: [
        Addon(price: 15, name: "Extra Espresso Drizzle"),
        Addon(price: 10, name: "Chocolate Shavings"),
        Addon(price: 20, name: "Amaretto Shot"),
      ],
    ),

// drinks

    // Iced Coffee
    Food(
      name: "Iced Coffee",
      description:
          "Chilled coffee served over ice, with a splash of milk and optional sweetener.",
      imagePath: "lib/images/Drinks/Iced_coffee.jpg",
      price: 90,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 15, name: "Caramel Syrup"),
        Addon(price: 10, name: "Whipped Cream"),
        Addon(price: 20, name: "Coffee Jelly"),
      ],
    ),

    // Lemon Mint Cooler
    Food(
      name: "Lemon Mint Cooler",
      description:
          "A refreshing drink made with fresh lemon juice, mint leaves, and sparkling water.",
      imagePath: "lib/images/Drinks/Lemon_mint_cooler.jpg",
      price: 80,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 10, name: "Extra Mint"),
        Addon(price: 5, name: "Lemon Slices"),
        Addon(price: 15, name: "Honey"),
      ],
    ),

    // Mango Lassi
    Food(
      name: "Mango Lassi",
      description:
          "A smooth and creamy yogurt-based drink blended with ripe mangoes and a hint of cardamom.",
      imagePath: "lib/images/Drinks/Mango_lassi.jpeg",
      price: 100,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 15, name: "Extra Mango"),
        Addon(price: 10, name: "Pistachio Garnish"),
        Addon(price: 5, name: "Rose Water"),
      ],
    ),

    // Strawberry Milkshake
    Food(
      name: "Strawberry Milkshake",
      description:
          "A thick and creamy milkshake made with fresh strawberries, vanilla ice cream, and milk.",
      imagePath: "lib/images/Drinks/Strawberry_milkshake.jpeg",
      price: 110,
      catagory: FoodCatagory.drinks,
      availableAddons: [
        Addon(price: 15, name: "Extra Strawberries"),
        Addon(price: 10, name: "Whipped Cream"),
        Addon(price: 20, name: "Strawberry Jam Swirl"),
      ],
    ),

    // Virgin Mojito
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
