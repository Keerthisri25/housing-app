import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'property_details_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _selectedPropertyType = 'All';
  List<String> propertyTypes = ['All', 'Apartment', 'House', 'Villa'];
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  Future<void> toggleSaveProperty(String propertyId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // User not logged in, handle appropriately
      return;
    }

    final savedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedProperties')
        .doc(propertyId);

    final doc = await savedRef.get();
    if (doc.exists) {
      await savedRef.delete(); // Unsave the property if already saved
    } else {
      await savedRef.set({'savedAt': Timestamp.now()}); // Save the property
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedPropertyType,
                  icon: const Icon(Icons.filter_list),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPropertyType = newValue!;
                    });
                  },
                  items: propertyTypes
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('properties')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No properties found'));
                }

                final filteredProperties = snapshot.data!.docs.where((property) {
                  final name = property['name'] as String? ?? '';
                  final propertyType = property['propertyType'] as String? ?? '';
                  final city = property['city'] as String? ?? '';
                  final locality = property['locality'] as String? ?? '';

                  final matchesSearchTerm = name
                          .toLowerCase()
                          .contains(_searchTerm.toLowerCase()) ||
                      propertyType
                          .toLowerCase()
                          .contains(_searchTerm.toLowerCase()) ||
                      city.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                      locality.toLowerCase().contains(_searchTerm.toLowerCase());

                  final matchesPropertyType = _selectedPropertyType == 'All' ||
                      propertyType == _selectedPropertyType;

                  return matchesSearchTerm && matchesPropertyType;
                }).toList();

                if (filteredProperties.isEmpty) {
                  return const Center(child: Text('No matching properties found'));
                }

                return ListView.builder(
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = filteredProperties[index];
                    final propertyId = property.id;
                    final imageUrl = property['imageUrl'] as String?;
                    final name = property['name'] as String? ?? 'No Name';
                    final propertyType = property['propertyType'] as String? ?? 'Unknown';
                    final bhk = property['bhk'] as String? ?? 'N/A';
                    final area = property['area'] as String? ?? 'N/A';
                    final furnishType = property['furnishType'] as String? ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        leading: imageUrl != null
                            ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 80),
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: $propertyType'),
                            Text('BHK: $bhk'),
                            Text('Area: $area sq. ft'),
                            Text('Furnishing: $furnishType'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          onPressed: () {
                            toggleSaveProperty(propertyId);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailPage(
                                name: name,
                                propertyType: propertyType,
                                price: property['price'] ?? 'No price',
                                city: property['city'] ?? 'No City',
                                locality: property['locality'] ?? 'No Locality',
                                bhk: bhk,
                                area: area,
                                furnishType: furnishType,
                                imageUrl: imageUrl ?? '',
                              ),
                            ),
                          );
                        },
                        isThreeLine: true,
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
