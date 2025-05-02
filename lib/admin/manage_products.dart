import 'package:flutter/material.dart';
import 'package:food_delivery_app/admin/admin_home.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/models/food.dart';
import 'package:food_delivery_app/models/restauarant.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
// ignore: depend_on_referenced_packages, unused_import
import 'package:path/path.dart' as path;

class ManageProducts extends StatefulWidget {
  final int? initialCategoryIndex;
  
  const ManageProducts({
    super.key, 
    this.initialCategoryIndex,
  });

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts>
    with SingleTickerProviderStateMixin {
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
  String _imagePath = '';

  final List<Addon> _addons = [];
  FoodCatagory _selectedCategory = FoodCatagory.bugers;

  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingIndex;

  // Tab controller for category-based tabs
  late TabController _tabController;

  // Map to store category-specific foods
  Map<FoodCatagory, List<Food>> _categorizedFoods = {};

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCatagory.values.length, vsync: this);
    
    // Set initial tab based on passed initialCategoryIndex
    if (widget.initialCategoryIndex != null && 
        widget.initialCategoryIndex! < FoodCatagory.values.length) {
      _tabController.index = widget.initialCategoryIndex!;
      _selectedCategory = FoodCatagory.values[widget.initialCategoryIndex!];
    }

    // Set the initial tab based on the selected category
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = FoodCatagory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addonNameController.dispose();
    _addonPriceController.dispose();
    _imageUrlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Function to validate and normalize image URL
  // ignore: unused_element
  String? _validateImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'Image URL is required';
    }

    // Only allow local image paths
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return 'Please use a local image path instead of a URL';
    }

    // Check if the path follows the correct format for the image folders
    if (!url.contains('lib/images/') && !url.contains('images/')) {
      return 'Image path should be in the format: lib/images/Category/image_name.jpg';
    }

    return null;
  }

  // Method to categorize foods from the menu
  // ignore: unused_element
  void _categorizeFoods(List<Food> menu) {
    _categorizedFoods = {};

    // Initialize empty lists for each category
    for (var category in FoodCatagory.values) {
      _categorizedFoods[category] = [];
    }

    // Populate the maps with foods
    for (var food in menu) {
      _categorizedFoods[food.catagory]?.add(food);
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

  // Method to define standard image sizes for consistent UI
  Map<String, double> _getImageDimensions(String imageType) {
    // Define standard sizes for different UI components
    switch (imageType) {
      case 'form_preview':
        return {'height': 160.0, 'width': 160.0};
      case 'grid_item':
        return {'height': 100.0, 'width': 100.0};
      case 'placeholder':
        return {'height': 120.0, 'width': 120.0};
      default:
        return {'height': 120.0, 'width': 120.0};
    }
  }

  // Function to display image with error handling
  Widget _buildNetworkImage(String imagePath,
      {double? height,
      double? width,
      BoxFit fit = BoxFit.cover,
      String sizeType = 'default'}) {
    // Get standard dimensions if not specified
    if (height == null || width == null) {
      final dimensions = _getImageDimensions(sizeType);
      height = height ?? dimensions['height'];
      width = width ?? dimensions['width'];
    }

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
        errorBuilder: (_, __, ___) =>
            _buildImageFailurePlaceholder(height!, width),
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
                        return _tryExistingCategoryImage(
                            height!, width, fit, sizeType);
                      },
                    );
                  }
                  return _tryExistingCategoryImage(
                      height!, width, fit, sizeType);
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
                errorBuilder: (_, __, ___) =>
                    _tryExistingCategoryImage(height!, width, fit, sizeType),
              );
            }
            return _tryExistingCategoryImage(height!, width, fit, sizeType);
          },
        );
      },
    );
  }

  // Try to load a known existing image for the current category
  Widget _tryExistingCategoryImage(
      double height, double? width, BoxFit fit, String sizeType) {
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
    final paths =
        knownImages[_selectedCategory] ?? knownImages[FoodCatagory.bugers]!;

    return _tryMultiplePaths(paths, height, width, fit, sizeType);
  }

  // Helper to try multiple image paths
  Widget _tryMultiplePaths(List<String> paths, double height, double? width,
      BoxFit fit, String sizeType) {
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
          return _tryMultiplePaths(remaining, height, width, fit, sizeType);
        }
      },
    );
  }

  // Simple placeholder for when all image loading attempts fail
  Widget _buildImageFailurePlaceholder(double height, double? width) {
    final dimensions = _getImageDimensions('placeholder');
    return Container(
      height: height,
      width: width ?? dimensions['width'],
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported,
                color: Colors.grey, size: height > 100 ? 40 : 30),
            if (height > 120)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Image not found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
          ],
        ),
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
            String categoryFolder = _getCategoryFolder(_selectedCategory);
            _imagePath = 'lib/images/$categoryFolder/$fileName';
          } else {
            // For mobile platforms, handle file path
            _imagePath = result.files.first.path!;
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

  Future<void> _saveProduct() async {
    // Validate form fields
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        (!_hasSelectedImage && !_isEditing)) {
      String errorMessage = 'Please fill all required fields';
      if (!_hasSelectedImage && !_isEditing) {
        errorMessage = 'Please select an image for the product';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Ensure list is initialized if empty
      List<Addon> addons = List.from(_addons);

      // Determine the image path to use
      String finalImagePath = _isEditing && !_hasSelectedImage
          ? (_imagePath.isNotEmpty
              ? _imagePath
              : _getCategoryDefaultImage(_selectedCategory))
          : _imagePath;

      final food = Food(
        name: _nameController.text,
        description: _descriptionController.text,
        imagePath: finalImagePath,
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
            const SnackBar(content: Text('Product updated successfully')),
          );
        } else {
          restaurant.addFood(food);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
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
      _addonNameController.clear();
      _addonPriceController.clear();
      _addons.clear();
      _imagePath = '';
      _isEditing = false;
      _editingIndex = null;
      
      // Set default category to the currently selected tab
      _selectedCategory = FoodCatagory.values[_tabController.index];

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
      _imagePath = food.imagePath;
      _selectedCategory = food.catagory;
      _addons.clear();
      _addons.addAll(food.availableAddons);
      _isEditing = true;
      _editingIndex = index;

      // Reset image selection state for edit
      _selectedImageFile = null;
      _webImageBytes = null;
      _hasSelectedImage = false; // We're loading from existing path

      // Set the tab to match the food's category
      _tabController.animateTo(FoodCatagory.values.indexOf(food.catagory));
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
        const SnackBar(content: Text('Product deleted successfully')),
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

    // Categorize foods whenever the menu changes
    _categorizeFoods(restaurant.menu);

    // Get the theme colors
    final primaryColor = Theme.of(context).primaryColor;
    // ignore: unused_local_variable
    final surfaceColor = Theme.of(context).colorScheme.surface;
    // ignore: unused_local_variable
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              _isEditing ? Icons.edit_note : Icons.restaurant_menu,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              _isEditing ? 'Edit Product' : 'Manage Products',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminHome()));
          },
          tooltip: 'Back to Admin Home',
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel, size: 24),
              onPressed: _clearForm,
              tooltip: 'Cancel Editing',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: () {
              setState(() {
                // Refresh the page
                _categorizeFoods(restaurant.menu);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Products refreshed')),
              );
            },
            tooltip: 'Refresh Products',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          tabs: FoodCatagory.values.map((category) {
            return Tab(
              text: category.name,
              icon: _getCategoryIcon(category),
            );
          }).toList(),
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;

        return Column(
          children: [
            // Form and Product display in responsive layout
            Expanded(
              child: isWideScreen
                  // Wide screen layout (web) - Side by side form and products
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form section in a scrollable container
                        SizedBox(
                          width: 400, // Fixed width for form
                          child: _buildProductForm(context),
                        ),

                        // Vertical divider
                        const VerticalDivider(width: 1, thickness: 1),

                        // Product grid in scrollable container
                        Expanded(
                          child: _buildProductsGrid(context),
                        ),
                      ],
                    )
                  // Narrow screen layout (mobile) - Stacked form and products
                  : _buildTabView(context),
            ),
          ],
        );
      }),
    );
  }

  // Build the product form
  Widget _buildProductForm(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 200, // Adjust for AppBar and margins
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEditing ? 'Edit Product' : 'Add New Product',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Image preview and picker
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        "Product Image",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_hasSelectedImage && kIsWeb && _webImageBytes != null)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _webImageBytes!,
                                height:
                                    _getImageDimensions('form_preview')['height'],
                                width: _getImageDimensions('form_preview')['width'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      else if (_hasSelectedImage &&
                          !kIsWeb &&
                          _selectedImageFile != null &&
                          _selectedImageFile!.path != null)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_selectedImageFile!.path!),
                                height:
                                    _getImageDimensions('form_preview')['height'],
                                width: _getImageDimensions('form_preview')['width'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      else if (_imagePath.isNotEmpty)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildNetworkImage(
                                _imagePath,
                                sizeType: 'form_preview',
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Container(
                            height: _getImageDimensions('form_preview')['height'],
                            width: _getImageDimensions('form_preview')['width'],
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text(
                                    'No Image Selected',
                                    style:
                                        TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Image picker button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(_hasSelectedImage || _imagePath.isNotEmpty
                              ? 'Change Image'
                              : 'Select Image'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product details fields
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fastfood),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Selection
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonFormField<FoodCatagory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Food Category',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: FoodCatagory.values.map((category) {
                      return DropdownMenuItem<FoodCatagory>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category).icon,
                              color: _getCategoryColor(category),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getCategoryColor(category),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (FoodCatagory? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Add-ons section
                Card(
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
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
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  dense: true,
                                  title: Text(addon.name),
                                  subtitle: Text('₹${addon.price}'),
                                  trailing: IconButton(
                                    icon:
                                        const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeAddon(index),
                                  ),
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
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _saveProduct,
                        icon: Icon(_isEditing ? Icons.update : Icons.add),
                        label: Text(_isEditing ? 'Update Product' : 'Add Product'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the products grid display
  Widget _buildProductsGrid(BuildContext context) {
    final restaurant = Provider.of<Restauarant>(context);
    final foodsInCategory = _categorizedFoods[_selectedCategory] ?? [];
    
    if (foodsInCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(_selectedCategory).icon,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_selectedCategory.name} items yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add items using the form',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Focus on the form
              },
              icon: const Icon(Icons.add_circle),
              label: const Text('Add New Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _calculateGridCrossAxisCount(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: foodsInCategory.length,
      itemBuilder: (context, index) {
        final food = foodsInCategory[index];
        final actualIndex = restaurant.menu.indexOf(food);
        
        return _buildFoodCard(food, actualIndex, true);
      },
    );
  }
  
  // Calculate optimal number of columns based on screen width
  int _calculateGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    return 2;
  }

  // Build tab view for mobile layout with better UI
  Widget _buildTabView(BuildContext context) {
    final restaurant = Provider.of<Restauarant>(context);
    
    return Column(
      children: [
        // Form section - reduced size on mobile
        Expanded(
          flex: 1,
          child: _buildProductForm(context),
        ),
        
        // Add a small divider between sections
        Container(
          height: 6,
          width: double.infinity,
          color: Colors.grey[200],
        ),
        
        // Label for products section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(_selectedCategory).icon,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                "${_selectedCategory.name} Products",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Products list section - Tab View
        Expanded(
          flex: 1,
          child: TabBarView(
            controller: _tabController,
            children: FoodCatagory.values.map((category) {
              final foodsInCategory = _categorizedFoods[category] ?? [];
              
              return foodsInCategory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(category).icon,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${category.name} items yet',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add items using the form above',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Set category and scroll to form
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: foodsInCategory.length,
                      itemBuilder: (context, index) {
                        final food = foodsInCategory[index];
                        final actualIndex = restaurant.menu.indexOf(food);
                        
                        return _buildFoodCard(food, actualIndex, false);
                      },
                    );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Build a food card (shared between grid and tab views)
  Widget _buildFoodCard(Food food, int actualIndex, bool isWeb) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: 'food_image_${food.name}',
                      child: _buildNetworkImage(
                        food.imagePath,
                        sizeType: 'grid_item',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                          onPressed: () => _editProduct(food, actualIndex),
                          tooltip: 'Edit Product',
                          iconSize: 16,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.white, size: 16),
                          onPressed: () =>
                              _showDeleteConfirmation(food, actualIndex),
                          tooltip: 'Delete Product',
                          iconSize: 16,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Category indicator
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(food.catagory),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      food.catagory.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Product details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₹${food.price}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      food.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Add-ons indicator
                  if (food.availableAddons.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${food.availableAddons.length} add-on${food.availableAddons.length > 1 ? 's' : ''}",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get color for category tag
  Color _getCategoryColor(FoodCatagory category) {
    switch (category) {
      case FoodCatagory.bugers:
        return Colors.orange;
      case FoodCatagory.pizza:
        return Colors.red;
      case FoodCatagory.sides:
        return Colors.amber;
      case FoodCatagory.salads:
        return Colors.green;
      case FoodCatagory.drinks:
        return Colors.blue;
      case FoodCatagory.desserts:
        return Colors.purple;
      // ignore: unreachable_switch_default
      default:
        return Colors.grey;
    }
  }

  Icon _getCategoryIcon(FoodCatagory category) {
    switch (category) {
      case FoodCatagory.bugers:
        return const Icon(Icons.lunch_dining);
      case FoodCatagory.pizza:
        return const Icon(Icons.local_pizza);
      case FoodCatagory.sides:
        return const Icon(Icons.fastfood);
      case FoodCatagory.salads:
        return const Icon(Icons.eco);
      case FoodCatagory.drinks:
        return const Icon(Icons.local_drink);
      case FoodCatagory.desserts:
        return const Icon(Icons.cake);
      // ignore: unreachable_switch_default
      default:
        return const Icon(Icons.restaurant);
    }
  }
}
