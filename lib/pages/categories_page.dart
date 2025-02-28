import 'package:flutter/material.dart';

import 'explore.dart';
import 'rent_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose one',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // 'Buy' card
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
                title: const Text(
                  'Buy',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Explore items to purchase'),
                onTap: () {
                  // Navigate to the Explore page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExplorePage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // 'Sell' card
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.sell,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
                title: const Text(
                  'Sell',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('List your items for sale'),
                onTap: () {
                  Navigator.pushNamed(
                      context, '/sell'); // Navigate to Sell page
                },
              ),
            ),
            const SizedBox(height: 16),
            // 'Rent' card
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
                title: const Text(
                  'Rent',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Find rental options'),
                onTap: () {
                  // Navigate to Rent page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RentPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
