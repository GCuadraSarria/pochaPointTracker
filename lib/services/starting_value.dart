// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> setDefaultValueForAllPlayers() async {
  try {
    // Get a reference to the players collection
    CollectionReference players = FirebaseFirestore.instance.collection('players');

    // Query all user documents
    QuerySnapshot querySnapshot = await players.get();

    // Create a batch operation
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Iterate over each user document and update the field 'doIplay' to false
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'doIplay': false});
    }

    // Commit the batch operation
    await batch.commit();

    print('Default value set successfully for all players.');
  } catch (e) {
    print('Error setting default value for all players: $e');
  }
}
