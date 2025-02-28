import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Properties'),
        ),
        body: const Center(
          child: Text('Please log in to view saved properties'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Properties'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('savedProperties')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No saved properties found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final savedProperty = snapshot.data!.docs[index];
              final propertyId = savedProperty.id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('properties')
                    .doc(propertyId)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }
                  final property = snapshot.data!;
                  final name = property['name'] as String? ?? 'No Name';
                  final propertyType =
                      property['propertyType'] as String? ?? 'Unknown';
                  final imageUrl = property['imageUrl'] as String?;

                  return Card(
                    child: ListTile(
                      leading: imageUrl != null
                          ? Image.network(imageUrl,
                              width: 80, height: 80, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 80),
                      title: Text(name),
                      subtitle: Text('Type: $propertyType'),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark_remove),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('savedProperties')
                              .doc(propertyId)
                              .delete();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
