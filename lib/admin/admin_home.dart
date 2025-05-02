import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:food_delivery_app/admin/manage_products.dart';
import 'package:food_delivery_app/models/food.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.orange,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  // Perform logout logic here
                  Navigator.pushReplacementNamed(
                      context, '/user_home'); // or your login route
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child:
                        Icon(Icons.admin_panel_settings, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Text('Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      sideBar: SideBar(
        backgroundColor: Colors.orange,
        textStyle: const TextStyle(color: Colors.white),
        activeTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        activeIconColor: Colors.black,
        iconColor: Colors.white,
        items: const [
          AdminMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: '/dashboard',
          ),
          AdminMenuItem(
            icon: Icons.production_quantity_limits,
            title: 'Manage Products',
            route: '/manage_product',
          ),
          AdminMenuItem(
            icon: Icons.shopping_cart,
            title: 'Manage Orders',
            route: '/orders',
          ),
          
        ],
        selectedRoute: '/dashboard',
        onSelected: (item) {
          if (item.route != null) {
            Navigator.pushReplacementNamed(context, item.route!);
          }
        },
      ),
      body: const DashboardPage(),
    );
  }
}

// ---------------------- DASHBOARD CONTENT ----------------------

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Charts Row
          Row(
            children: [
              // Weekly Orders Chart
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Weekly Orders',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 150, child: WeeklyBarChart()),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Monthly Trend Chart
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Monthly Trend',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 150, child: MonthlyLineChart()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Yearly Distribution
          const Text(
            'Yearly Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 200, child: YearlyPieChart()),

          const SizedBox(height: 24),

          // Food Categories
          const Text(
            'Food Categories',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return FoodCategoryCard(index: index);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------- CATEGORY CARD ----------------------

class FoodCategoryCard extends StatelessWidget {
  final int index;
  const FoodCategoryCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Burgers',
      'Pizzas',
      'Salads',
      'Sides',
      'Desserts',
      'Drinks'
    ];
    
    // Map index to FoodCategory enum
    FoodCatagory getCategoryFromIndex(int index) {
      switch (index) {
        case 0:
          return FoodCatagory.bugers;
        case 1:
          return FoodCatagory.pizza;
        case 2:
          return FoodCatagory.salads;
        case 3:
          return FoodCatagory.sides;
        case 4:
          return FoodCatagory.desserts;
        case 5:
          return FoodCatagory.drinks;
        default:
          return FoodCatagory.bugers;
      }
    }
    
    // Get image path for each category
    String getCategoryImagePath(int index) {
      switch (index) {
        case 0: // Burgers
          return 'lib/images/Burger/burger.jpg';
        case 1: // Pizzas
          return 'lib/images/Pizza/Margherita_pizza.jpg';
        case 2: // Salads
          return 'lib/images/Salad/Caeser_salad.jpeg';
        case 3: // Sides
          return 'lib/images/Sides/Garlic_sides.jpg';
        case 4: // Desserts
          return 'lib/images/Desserts/Cheesecake.jpg';
        case 5: // Drinks
          return 'lib/images/Drinks/Virgin_mojito.jpeg';
        default:
          return 'lib/images/Burger/burger.jpg';
      }
    }
    
    return GestureDetector(
      onTap: () {
        // Navigate to ManageProducts with the selected category
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageProducts(
              initialCategoryIndex: index,
            ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // Background food image covering the entire card
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                getCategoryImagePath(index),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to alternative path if the main one fails
                  return Image.asset(
                    getCategoryImagePath(index).replaceFirst('lib/', ''),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // If both paths fail, show a colored background instead
                      return Container(
                        color: _getCategoryColor(getCategoryFromIndex(index)).withOpacity(0.3),
                      );
                    },
                  );
                },
              ),
            ),
            // Semi-transparent overlay for better readability
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.orange[100]!.withOpacity(0.85),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCategoryIcon(getCategoryFromIndex(index)).icon,
                    size: 40,
                    color: _getCategoryColor(getCategoryFromIndex(index)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories[index],
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to manage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11, 
                      color: _getCategoryColor(getCategoryFromIndex(index)),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator in the bottom-right corner
            Positioned(
              bottom: 8,
              right: 8,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _getCategoryColor(getCategoryFromIndex(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Get color for category
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

// ---------------------- CHART WIDGETS ----------------------

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [8, 10, 14, 15, 13, 10, 6];
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 30,
              getTitlesWidget: (value, _) => Text(value.toInt().toString()),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(days[value.toInt()]);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].toDouble(),
                color: Colors.orange,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class MonthlyLineChart extends StatelessWidget {
  const MonthlyLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
        12, (index) => FlSpot(index.toDouble(), (index + 1) * 2 % 15 + 5));
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ];
                return Text(months[value.toInt() % 12]);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class YearlyPieChart extends StatelessWidget {
  const YearlyPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = List.generate(4, (i) {
      return PieChartSectionData(
        color: [Colors.orange, Colors.blue, Colors.green, Colors.purple][i],
        value: [40, 30, 20, 10][i].toDouble(),
        title: '${[40, 30, 20, 10][i]}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 4,
      ),
    );
  }
}
