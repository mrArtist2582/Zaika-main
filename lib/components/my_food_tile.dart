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
    // Universal fallback image to use when everything else fails
    const String universalFallbackUrl = 'https://i.imgur.com/CsCgN7p.png';
    
    // Check if the path is a URL (starts with http:// or https://)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Use Image.network for URLs
      return Image.network(
        imagePath,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        // Add error handling to display a fallback if network image fails to load
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading network image: $error');
          return Image.network(
            universalFallbackUrl,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              );
            },
          );
        },
        // Add loading indicator
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 100,
            width: 100,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      // Check if this is one of the problematic pizza, drinks, or desserts images
      if ((imagePath.contains('Pizza') || imagePath.contains('Drinks') || imagePath.contains('Desserts')) && _getMissingPizzaReplacement(imagePath) != null) {
        // Return a network image replacement
        return Image.network(
          _getMissingPizzaReplacement(imagePath)!,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading fallback image: $error');
            return Image.network(
              universalFallbackUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 100,
              width: 100,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        );
      }
      
      // Use Image.asset for other local asset paths
      return Image.asset(
        imagePath,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading asset image: $error');
          // Try with a universal fallback
          return Image.network(
            universalFallbackUrl,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          );
        },
      );
    }
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
