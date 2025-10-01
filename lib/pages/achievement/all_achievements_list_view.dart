import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllAchievementsListView extends StatelessWidget {
  const AllAchievementsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('achievements').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay logros aún'));
        }
        final achievements = snapshot.data!.docs;

        // Agrupa por categoría
        final Map<String, List<QueryDocumentSnapshot>> grouped = {};
        for (var achievement in achievements) {
          final category = achievement['category'] ?? 'Otros';
          grouped.putIfAbsent(category, () => []).add(achievement);
        }

        // Ordena cada grupo por el campo 'order'
        grouped.forEach((key, list) {
          list.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
        });

        // Muestra por categorías y orden
        return ListView(
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    entry.key[0].toUpperCase() + entry.key.substring(1),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...entry.value.map((achievement) {
                  final name = achievement['name'] ?? '';
                  final description = achievement['description'] ?? '';
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
