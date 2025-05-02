import 'package:flutter/material.dart';
import 'package:food_delivery_app/components/addons_bottom_sheet.dart';
import '../models/food.dart';


class MyFoodTile extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;

  const MyFoodTile({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                // Food Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildFoodImage(food.imagePath),
                ),
                const SizedBox(width: 15),

                // Food Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Name
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Food Price
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹${food.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Short Description
                      Text(
                        food.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Add to Cart Button
                ElevatedButton(
                  onPressed: () {
                    // Always show the bottom sheet, regardless of whether add-ons exist
                    _showAddonBottomSheet(context, food);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(color: Colors.white,fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Improved Divider for Light Mode
        Divider(
          color: Colors.grey.shade400,
          thickness: 0.8,
          indent: 15,
          endIndent: 15,
        ),
      ],
    );
  }

  // Helper method to determine and build the appropriate image widget
  Widget _buildFoodImage(String imagePath) {
    debugPrint('Loading image: $imagePath');
    
    // Try loading the image directly as specified in the path
    return _tryLoadImage(
      imagePath,
      onError: () {
        // If that fails, try removing 'lib/' prefix
        if (imagePath.startsWith('lib/')) {
          final noLibPath = imagePath.substring(4);
          debugPrint('Trying path without lib/: $noLibPath');
          
          return _tryLoadImage(
            noLibPath,
            onError: () => _getFallbackImageForPath(imagePath),
          );
        }
        
        // If the path doesn't start with 'lib/', try fallback directly
        return _getFallbackImageForPath(imagePath);
      },
    );
  }
  
  // Attempts to load an image with the given path
  Widget _tryLoadImage(String path, {required Widget Function() onError}) {
    return Image.asset(
      path,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image $path: $error');
        return onError();
      },
    );
  }
  
  // Determines which category the image belongs to and gets a fallback
  Widget _getFallbackImageForPath(String imagePath) {
    String? category;
    
    // Extract category from the path
    final pathParts = imagePath.split('/');
    if (pathParts.length >= 2) {
      for (final part in pathParts) {
        if (['Burger', 'Pizza', 'Salad', 'Desserts', 'Drinks', 'Sides'].contains(part)) {
          category = part;
          break;
        }
      }
    }
    
    category ??= _getCategoryNameFromEnum(food.catagory);
    
    return _loadCategoryFallback(category);
  }
  
  // Convert the enum to a string category name
  String _getCategoryNameFromEnum(FoodCatagory category) {
    switch (category) {
      case FoodCatagory.bugers:
        return 'Burger';
      case FoodCatagory.pizza:
        return 'Pizza';
      case FoodCatagory.sides:
        return 'Sides';
      case FoodCatagory.salads:
        return 'Salad';
      case FoodCatagory.drinks:
        return 'Drinks';
      case FoodCatagory.desserts:
        return 'Desserts';
      // ignore: unreachable_switch_default
      default:
        return 'Burger';
    }
  }
  
  // Load a fallback image based on the food category
  Widget _loadCategoryFallback(String category) {
    // Get specific fallback image for the category
    String fallbackPath = _getCategoryFallbackImage(category);
    debugPrint('Using category fallback: $fallbackPath');
    
    // Try direct loading of the fallback image
    return _tryLoadImage(
      fallbackPath,
      onError: () {
        // Try without 'lib/' prefix if that fails
        if (fallbackPath.startsWith('lib/')) {
          final noLibPath = fallbackPath.substring(4);
          return _tryLoadImage(
            noLibPath,
            onError: () => _buildFallbackContainer(),
          );
        } 
        return _buildFallbackContainer();
      },
    );
  }
  
  // Get a fallback image from the same food category
  String _getCategoryFallbackImage(String category) {
    switch (category) {
      case 'Burger':
        return 'lib/images/Burger/veg_burger.png';
      case 'Pizza':
        return 'lib/images/Pizza/Margherita_pizza.jpg';
      case 'Salad':
        return 'lib/images/Salad/Caeser_salad.jpeg';
      case 'Desserts':
        return 'lib/images/Desserts/Cheesecake.jpg';
      case 'Drinks':
        return 'lib/images/Drinks/Virgin_mojito.jpeg';
      case 'Sides':
        return 'lib/images/Sides/Loaded_fries.jpeg';
      default:
        // Default fallback is a burger
        return 'lib/images/Burger/veg_burger.png';
    }
  }

  // Helper method to build a standard fallback container
  Widget _buildFallbackContainer() {
    return Container(
      height: 100,
      width: 100,
      color: Colors.grey[300],
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  // Show bottom sheet for selecting add-ons
  void _showAddonBottomSheet(BuildContext context, Food food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      builder: (context) => AddonSelectionBottomSheet(food: food),
    );
  }
} 