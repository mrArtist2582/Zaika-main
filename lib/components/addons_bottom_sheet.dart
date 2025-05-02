import 'package:flutter/material.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/models/restauarant.dart';
import 'package:provider/provider.dart';


class AddonSelectionBottomSheet extends StatefulWidget {
  final Food food;

  const AddonSelectionBottomSheet({super.key, required this.food});

  @override
  _AddonSelectionBottomSheetState createState() =>
      _AddonSelectionBottomSheetState();
}

class _AddonSelectionBottomSheetState extends State<AddonSelectionBottomSheet> {
  List<Addon> selectedAddons = [];

  // Calculate only the add-on price separately
  double get totalAddonPrice =>
      selectedAddons.fold(0, (sum, addon) => sum + addon.price);

  // Helper method to build the appropriate image widget
  Widget _buildFoodImage(String imagePath) {
    // First attempt to load with direct asset path
    return Image.asset(
      imagePath,
      height: 70,
      width: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading direct image path: $error');
        
        // Try without lib/ prefix if original path fails
        if (imagePath.startsWith('lib/')) {
          String altPath = imagePath.substring(4);
          debugPrint('Trying without lib/ prefix: $altPath');
          
          return Image.asset(
            altPath,
            height: 70,
            width: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading image without lib/ prefix: $error');
              
              // Try a category-based fallback
              String category = _extractCategoryFromPath(imagePath);
              String fallbackPath = _getCategoryFallbackImage(category);
              
              return Image.asset(
                fallbackPath,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Final attempt: use a network fallback
                  String? networkFallback = _getMissingPizzaReplacement(imagePath);
                  if (networkFallback != null) {
                    return Image.network(
                      networkFallback,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackContainer();
                      },
                    );
                  } else {
                    return _buildFallbackContainer();
                  }
                },
              );
            },
          );
        } else {
          // For non-lib paths, try fallback directly
          String category = _extractCategoryFromPath(imagePath);
          String fallbackPath = _getCategoryFallbackImage(category);
          
          return Image.asset(
            fallbackPath, 
            height: 70,
            width: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Final attempt: use a network fallback
              String? networkFallback = _getMissingPizzaReplacement(imagePath);
              if (networkFallback != null) {
                return Image.network(
                  networkFallback,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackContainer();
                  },
                );
              } else {
                return _buildFallbackContainer();
              }
            },
          );
        }
      },
    );
  }
  
  // Extract category from image path
  String _extractCategoryFromPath(String path) {
    final pathParts = path.split('/');
    for (final part in pathParts) {
      if (['Burger', 'Pizza', 'Salad', 'Desserts', 'Drinks', 'Sides'].contains(part)) {
        return part;
      }
    }
    return 'Burger'; // Default category if none found
  }
  
  // Get category-specific fallback image
  String _getCategoryFallbackImage(String category) {
    switch (category) {
      case 'Pizza':
        return 'lib/images/Pizza/Margherita_pizza.jpg';
      case 'Burger':
        return 'lib/images/Burger/veg_burger.png';
      case 'Salad':
        return 'lib/images/Salad/Caeser_salad.jpeg';
      case 'Desserts':
        return 'lib/images/Desserts/Cheesecake.jpg';
      case 'Drinks':
        return 'lib/images/Drinks/Virgin_mojito.jpeg';
      case 'Sides':
        return 'lib/images/Sides/Loaded_fries.jpeg';
      default:
        return 'lib/images/Burger/veg_burger.png';
    }
  }
  
  // Simple fallback container widget
  Widget _buildFallbackContainer() {
    return Container(
      height: 70,
      width: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  // Helper method to provide fallback URLs for known missing images
  String? _getMissingPizzaReplacement(String originalPath) {
    // Map of original paths to fallback URLs - using direct image URLs to avoid redirects
    final Map<String, String> replacements = {
      // Pizza replacements
      'lib/images/Pizza/White_pizza.jpg': 'https://i.imgur.com/gQZSBFY.jpg',
      'lib/images/Pizza/Pepproni_pizza.jpg': 'https://i.imgur.com/BzfG6qQ.jpg',
      'lib/images/Pizza/Supreme_pizza.jpg': 'https://i.imgur.com/KY1mVxd.jpg',
      'lib/images/Pizza/Vegetable_pizza.jpg': 'https://i.imgur.com/2b0qfoB.jpg',
      'lib/images/Pizza/Margherita_pizza.jpg': 'https://i.imgur.com/xLs2ITZ.jpg',
      // Drink replacements
      'lib/images/Drinks/Orange_juice.jpeg': 'https://i.imgur.com/a7pKANL.jpg',
      'lib/images/Drinks/Choco_milks.jpeg': 'https://i.imgur.com/bNDUlc9.jpg',
      'lib/images/Drinks/Cranberry.jpg': 'https://i.imgur.com/uKmw1nK.jpg',
      'lib/images/Drinks/Fresh_lime.jpg': 'https://i.imgur.com/TkXWACX.jpg',
      // Dessert replacements
      'lib/images/Desserts/Molten_lava_cake.jpg': 'https://i.imgur.com/BU3boH3.jpg',
      'lib/images/Desserts/Cheese_cake.jpg': 'https://i.imgur.com/OJyoN8H.jpg',
      'lib/images/Desserts/Gulab_jamun.jpg': 'https://i.imgur.com/b5zK1hd.jpg',
      'lib/images/Desserts/Rasmalai.jpg': 'https://i.imgur.com/jZEaY3q.jpg',
      'lib/images/Desserts/Oreo_shake.jpg': 'https://i.imgur.com/s84rCUz.jpg',
      'lib/images/Desserts/Choco_brownie.jpeg': 'https://i.imgur.com/l6RAPzW.jpg',
      'lib/images/Desserts/Cookie.jpeg': 'https://i.imgur.com/7oCVJgF.jpg',
      'lib/images/Desserts/Ice_cream.jpeg': 'https://i.imgur.com/kfqJzMV.jpg',
      'lib/images/Desserts/Mousse.jpeg': 'https://i.imgur.com/Hvq53aj.jpg',
    };
    
    return replacements[originalPath];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Customize Your Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Food Details
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildFoodImage(widget.food.imagePath),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(widget.food.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Text(
                  '₹${widget.food.price + totalAddonPrice}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Add-ons Selection
            Expanded(
              child: widget.food.availableAddons.isEmpty
                  ? Center(
                      child: Text(
                        "No add-ons available for this item",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView(
                      children: widget.food.availableAddons.map((addon) {
                        return CheckboxListTile(
                          title:
                              Text(addon.name, style: const TextStyle(fontSize: 14)),
                          subtitle: Text('₹${addon.price}',
                              style: const TextStyle(color: Colors.green)),
                          value: selectedAddons.contains(addon),
                          onChanged: (value) {
                            setState(() {
                              if (selectedAddons.contains(addon)) {
                                selectedAddons.remove(addon);
                              } else {
                                selectedAddons.add(addon);
                              }
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        );
                      }).toList(),
                    ),
            ),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<Restauarant>(context, listen: false)
                      .addToCart(widget.food, selectedAddons);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
