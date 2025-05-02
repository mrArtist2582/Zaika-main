import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/models/restauarant.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

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

  // Variables for file picker
  PlatformFile? _selectedImageFile;
  Uint8List? _webImageBytes;
  bool _hasSelectedImage = false;

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
    
    // Only allow local image paths
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return 'Please use a local image path instead of a URL';
    }

    // Check if the path follows the correct format for the image folders
    if (!url.contains('lib/images/') && 
        !url.contains('images/')) {
      return 'Image path should be in the format: lib/images/Category/image_name.jpg';
    }
    
    return null;
  }

  // Function to display image with error handling
  Widget _buildNetworkImage(String imagePath, {double height = 150, double? width, BoxFit fit = BoxFit.cover}) {
    if (kDebugMode) {
      print('Attempting to load image: $imagePath');
    }
    
    // Check if this is a network URL (shouldn't be, but just in case)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath, 
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildImageFailurePlaceholder(height, width),
      );
    }
    
    // First attempt with the direct path
    return Image.asset(
      imagePath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          print('Failed to load direct path: $imagePath, Error: $error');
        }
        
        // Second attempt: Try without "lib/" prefix
        if (imagePath.startsWith('lib/')) {
          String altPath = imagePath.substring(4);
          if (kDebugMode) {
            print('Trying without lib/ prefix: $altPath');
          }
          
          return Image.asset(
            altPath,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              if (kDebugMode) {
                print('Failed to load without lib/ prefix: $altPath');
              }
              
              // Third attempt: Use a category fallback
              String fallbackPath = _getCategoryDefaultImage(_selectedCategory);
              
              return Image.asset(
                fallbackPath,
                height: height,
                width: width,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  if (kDebugMode) {
                    print('Failed to load fallback: $fallbackPath');
                  }
                  
                  // Fourth attempt: Try fallback without lib/ prefix
                  if (fallbackPath.startsWith('lib/')) {
                    String finalFallbackPath = fallbackPath.substring(4);
                    return Image.asset(
                      finalFallbackPath,
                      height: height,
                      width: width,
                      fit: fit,
                      errorBuilder: (_, __, ___) {
                        // Fifth attempt: Try existing image for this category
                        return _tryExistingCategoryImage(height, width, fit);
                      },
                    );
                  }
                  return _tryExistingCategoryImage(height, width, fit);
                },
              );
            },
          );
        }
        
        // For paths not starting with lib/, try using the category fallback directly
        String fallbackPath = _getCategoryDefaultImage(_selectedCategory);
        
        return Image.asset(
          fallbackPath,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            if (fallbackPath.startsWith('lib/')) {
              String finalFallbackPath = fallbackPath.substring(4);
              return Image.asset(
                finalFallbackPath,
                height: height,
                width: width,
                fit: fit,
                errorBuilder: (_, __, ___) => _tryExistingCategoryImage(height, width, fit),
              );
            }
            return _tryExistingCategoryImage(height, width, fit);
          },
        );
      },
    );
  }
  
  // Try to load a known existing image for the current category
  Widget _tryExistingCategoryImage(double height, double? width, BoxFit fit) {
    // Hard-coded paths to images that should exist in each category
    final Map<FoodCatagory, List<String>> knownImages = {
      FoodCatagory.bugers: [
        'lib/images/Burger/veg_burger.png', 
        'images/Burger/veg_burger.png',
      ],
      FoodCatagory.pizza: [
        'lib/images/Pizza/Margherita_pizza.jpg',
        'images/Pizza/Margherita_pizza.jpg',
      ],
      FoodCatagory.salads: [
        'lib/images/Salad/Caeser_salad.jpeg',
        'images/Salad/Caeser_salad.jpeg',
      ],
      FoodCatagory.desserts: [
        'lib/images/Desserts/Cheesecake.jpg',
        'images/Desserts/Cheesecake.jpg',
      ],
      FoodCatagory.drinks: [
        'lib/images/Drinks/Virgin_mojito.jpeg',
        'images/Drinks/Virgin_mojito.jpeg',
      ],
      FoodCatagory.sides: [
        'lib/images/Sides/Garlic_sides.jpg',
        'images/Sides/Garlic_sides.jpg',
      ],
    };
    
    // Try each path for the current category
    final paths = knownImages[_selectedCategory] ?? knownImages[FoodCatagory.bugers]!;
    
    return _tryMultiplePaths(paths, height, width, fit);
  }
  
  // Helper to try multiple image paths
  Widget _tryMultiplePaths(List<String> paths, double height, double? width, BoxFit fit) {
    if (paths.isEmpty) {
      return _buildImageFailurePlaceholder(height, width);
    }
    
    String path = paths.first;
    List<String> remaining = paths.sublist(1);
    
    return Image.asset(
      path,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) {
        if (remaining.isEmpty) {
          return _buildImageFailurePlaceholder(height, width);
        } else {
          return _tryMultiplePaths(remaining, height, width, fit);
        }
      },
    );
  }
  
  // Simple placeholder for when all image loading attempts fail
  Widget _buildImageFailurePlaceholder(double height, double? width) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      ),
    );
  }

  // Helper method to get default image path based on food category
  String _getCategoryDefaultImage(FoodCatagory category) {
    // Return a default image path based on the food category
    switch (category) {
      case FoodCatagory.bugers:
        return 'lib/images/Burger/burger.jpg';
      case FoodCatagory.pizza:
        return 'lib/images/Pizza/Margherita_pizza.jpg';
      case FoodCatagory.sides:
        return 'lib/images/Sides/Garlic_sides.jpg';
      case FoodCatagory.salads:
        return 'lib/images/Salad/Caeser_salad.jpeg';
      case FoodCatagory.drinks:
        return 'lib/images/Drinks/Virgin_mojito.jpeg';
      case FoodCatagory.desserts:
        return 'lib/images/Desserts/Cheesecake.jpg';
      // ignore: unreachable_switch_default
      default:
        return 'lib/images/Burger/burger.jpg';
    }
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

  // Method to pick an image using FilePicker
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null) {
        setState(() {
          _selectedImageFile = result.files.first;
          _hasSelectedImage = true;
          
          // Handle web platform specifically
          if (kIsWeb) {
            _webImageBytes = result.files.first.bytes;
            // For web, we'll create a path-like structure to mimic the folder structure
            String fileName = result.files.first.name;
            // ignore: unused_local_variable
            String extension = path.extension(fileName).toLowerCase();
            String categoryFolder = _getCategoryFolder(_selectedCategory);
            _imageUrlController.text = 'lib/images/$categoryFolder/$fileName';
          } else {
            // For mobile platforms, handle file path
            _imageUrlController.text = result.files.first.path!;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  // Helper method to get the appropriate folder name based on category
  String _getCategoryFolder(FoodCatagory category) {
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
      _imageUrlController.clear();
      _addonNameController.clear();
      _addonPriceController.clear();
      _addons.clear();
      _selectedCategory = FoodCatagory.bugers;
      _isEditing = false;
      _editingIndex = null;
      
      // Reset image picker variables
      _selectedImageFile = null;
      _webImageBytes = null;
      _hasSelectedImage = false;
    });
  }

  void _editProduct(Food food, int index) {
    setState(() {
      _nameController.text = food.name;
      _descriptionController.text = food.description;
      _priceController.text = food.price.toString();
      _imageUrlController.text = food.imagePath;
      _selectedCategory = food.catagory;
      _addons.clear();
      _addons.addAll(food.availableAddons);
      _isEditing = true;
      _editingIndex = index;
      
      // Reset image selection state for edit
      _selectedImageFile = null;
      _webImageBytes = null;
      _hasSelectedImage = false; // We're loading from existing path
    });
  }

  void _showDeleteConfirmation(Food food, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: Text("Are you sure you want to delete '${food.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                _deleteProduct(food, index);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Food food, int index) {
    try {
      final restaurant = Provider.of<Restauarant>(context, listen: false);
      restaurant.removeFood(food);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
      // If we were editing this product, clear the form
      if (_isEditing && _editingIndex == index) {
        _clearForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
      if (kDebugMode) {
        print('Delete product error: $e');
      }
    }
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
                  if (_hasSelectedImage && kIsWeb && _webImageBytes != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.memory(
                        _webImageBytes!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (_hasSelectedImage && !kIsWeb && _selectedImageFile != null && _selectedImageFile!.path != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.file(
                        File(_selectedImageFile!.path!),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (_imageUrlController.text.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: _buildNetworkImage(_imageUrlController.text),
                    ),
                  
                  // Image path field and image picker button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image Path',
                              hintText: 'lib/images/category/food_name.jpg',
                              border: OutlineInputBorder(),
                            ),
                            validator: _validateImageUrl,
                            onChanged: (value) {
                              setState(() {
                                // Reset selected image flag if path is manually changed
                                if (_hasSelectedImage) {
                                  _hasSelectedImage = false;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ],
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editProduct(food, index),
                          tooltip: 'Edit Product',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(food, index),
                          tooltip: 'Delete Product',
                        ),
                      ],
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
