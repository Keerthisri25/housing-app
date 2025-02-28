import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rental_details.dart'; // Import the RentalDetailPage

class TenantPage extends StatefulWidget {
  const TenantPage({super.key});

  @override
  TenantPageState createState() => TenantPageState();
}

class TenantPageState extends State<TenantPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Available rental options'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rentals')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No rental properties found'));
                }

                // Filter properties based on search term
                final filteredProperties =
                    snapshot.data!.docs.where((property) {
                  final name = property['name'] as String? ?? '';
                  final city = property['city'] as String? ?? '';
                  final locality = property['locality'] as String? ?? '';

                  // Check if property matches search term
                  final matchesSearchTerm = name
                          .toLowerCase()
                          .contains(_searchTerm.toLowerCase()) ||
                      city.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                      locality
                          .toLowerCase()
                          .contains(_searchTerm.toLowerCase());

                  return matchesSearchTerm;
                }).toList();

                if (filteredProperties.isEmpty) {
                  return const Center(
                      child: Text('No matching rental properties found'));
                }

                return ListView.builder(
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = filteredProperties[index];
                    final imageUrl = property['imageUrl'] as String?;
                    final name = property['name'] as String? ?? 'No Name';
                    final rent = property['rent'] as String? ?? 'N/A';
                    final city = property['city'] as String? ?? 'Unknown City';
                    final locality =
                        property['locality'] as String? ?? 'Unknown Locality';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        leading: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 80),
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('City: $city'),
                            Text('Locality: $locality'),
                            Text('Rent: ₹$rent'),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          // Navigate to RentalDetailPage on tap
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RentalDetailPage(
                                name: property['name'] ?? 'No Name',
                                propertyType:
                                    property['propertyType'] ?? 'Unknown Type',
                                city: property['city'] ?? 'No City',
                                locality: property['locality'] ?? 'No Locality',
                                rent: property['rent'] ?? 'No rent',
                                bhk: property['bhk'] ?? 'N/A',
                                area: property['area'] ?? 'N/A',
                                furnishType:
                                    property['furnishType'] ?? 'Unfurnished',
                                imageUrl: property['imageUrl'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
