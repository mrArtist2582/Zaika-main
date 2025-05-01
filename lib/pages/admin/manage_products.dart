import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/models/restauarant.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addonNameController = TextEditingController();
  final TextEditingController _addonPriceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final List<Addon> _addons = [];
  FoodCatagory _selectedCategory = FoodCatagory.bugers;

  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingIndex;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addonNameController.dispose();
    _addonPriceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Function to validate and normalize image URL
  String? _validateImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'Image URL is required';
    }
    
    // If it's a file path (doesn't start with http), consider it valid
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return null;
    }
    
    // Validate URL format
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return 'URL must start with http:// or https://';
      }
      return null;
    } catch (e) {
      return 'Invalid URL format';
    }
  }

  // Function to safely display network image with error handling
  Widget _buildNetworkImage(String url, {double height = 150, double? width, BoxFit fit = BoxFit.cover}) {
    // Universal fallback image to use when everything else fails
    const String universalFallbackUrl = 'https://i.imgur.com/CsCgN7p.png';

    // Check if this is a URL or a file path
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // It's a URL, use Image.network
      return Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('Error loading image: $error');
          }
          // Try the universal fallback
          return Image.network(
            universalFallbackUrl,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                width: width,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 40),
                ),
              );
            },
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
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
      // It's a file path, use Image.asset but provide error handling
      return Image.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('Error loading asset image: $error');
          }
          
          // For well-known missing images, use fallback images
          final String? fallbackUrl = _getFallbackImageUrl(url);
          if (fallbackUrl != null) {
            return Image.network(
              fallbackUrl,
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                // Try the universal fallback as last resort
                return Image.network(
                  universalFallbackUrl,
                  height: height,
                  width: width,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: height,
                      width: width,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                );
              },
            );
          }
          
          // Try the universal fallback for unknown assets
          return Image.network(
            universalFallbackUrl,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                width: width,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              );
            },
          );
        },
      );
    }
  }

  // Helper method to provide fallback URLs for known missing images
  String? _getFallbackImageUrl(String originalPath) {
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

  void _addAddon() {
    if (_addonNameController.text.isNotEmpty &&
        _addonPriceController.text.isNotEmpty) {
      setState(() {
        _addons.add(
          Addon(
            name: _addonNameController.text,
            price: double.parse(_addonPriceController.text),
          ),
        );
        _addonNameController.clear();
        _addonPriceController.clear();
      });
    }
  }

  void _removeAddon(int index) {
    setState(() {
      _addons.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    // Validate form fields
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Validate image URL
    final imageUrlError = _validateImageUrl(_imageUrlController.text);
    if (imageUrlError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(imageUrlError)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Ensure list is initialized if empty
      List<Addon> addons = List.from(_addons);
      
      final food = Food(
        name: _nameController.text,
        description: _descriptionController.text,
        imagePath: _imageUrlController.text,
        price: double.parse(_priceController.text),
        catagory: _selectedCategory,
        availableAddons: addons,
      );

      try {
        final restaurant = Provider.of<Restauarant>(context, listen: false);

        if (_isEditing && _editingIndex != null) {
          // Use the food object at _editingIn as Fooddex from the restaurant menu
          Food oldFood = restaurant.menu[_editingIndex!];
          restaurant.updateFood(oldFood, food);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated')),
          );
        } else {
          restaurant.addFood(food);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added')),
          );
        }

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Provider error: $e')),
        );
        if (kDebugMode) {
          print('Provider error: $e');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      if (kDebugMode) {
        print('Save product error: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _addons.clear();
      _addonNameController.clear();
      _addonPriceController.clear();
      _imageUrlController.clear();
      _selectedCategory = FoodCatagory.bugers;
      _isEditing = false;
      _editingIndex = null;
    });
  }

  void _startEditing(Food food, int index) {
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _nameController.text = food.name;
      _descriptionController.text = food.description;
      _priceController.text = food.price.toString();
      _imageUrlController.text = food.imagePath;
      _selectedCategory = food.catagory;
      _addons.clear();
      _addons.addAll(food.availableAddons);
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = Provider.of<Restauarant>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Manage Products'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _clearForm,
              tooltip: 'Cancel Editing',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image URL preview
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  if (_imageUrlController.text.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: _buildNetworkImage(_imageUrlController.text),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        hintText: 'https://example.com/image.jpg',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateImageUrl,
                      onChanged: (value) {
                        setState(() {
                          // Trigger UI update when URL changes
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: DropdownButtonFormField<FoodCatagory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: FoodCatagory.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add-ons (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addonNameController,
                            decoration: const InputDecoration(
                              labelText: 'Add-on Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _addonPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Add-on Price',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addAddon,
                          icon: const Icon(Icons.add_circle),
                          color: Theme.of(context).primaryColor,
                          tooltip: 'Add Add-on',
                        )
                      ],
                    ),
                    if (_addons.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Current Add-ons:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _addons.length,
                        itemBuilder: (context, index) {
                          final addon = _addons[index];
                          return ListTile(
                            dense: true,
                            title: Text('${addon.name} - ₹${addon.price}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeAddon(index),
                            ),
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _saveProduct,
                    icon: Icon(_isEditing ? Icons.update : Icons.add),
                    label: Text(_isEditing ? 'Update Product' : 'Add Product'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
            const Divider(height: 40),
            const Text('Your Products:', 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold
              )
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: restaurant.menu.length,
              itemBuilder: (context, index) {
                final food = restaurant.menu[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _buildNetworkImage(food.imagePath, height: 50, width: 50),
                    ),
                    title: Text(food.name),
                    subtitle: Text(
                      food.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _startEditing(food, index),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
