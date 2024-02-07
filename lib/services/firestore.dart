import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of players
  final CollectionReference players =
      FirebaseFirestore.instance.collection('players');

  // Check if a player name already exists
  Future<bool> doesPlayerExist(String playerName) async {
    final QuerySnapshot queryResult =
        await players.where('name', isEqualTo: playerName).limit(1).get();

    return queryResult.docs.isNotEmpty;
  }

  // CREATE: add a new player
  Future<void> addPlayer(String playerName) async {
    try {
      // Add the new player document to the "players" collection
      await players.add({
        'name': playerName,
        'gamesPlayed': 0,
        'winGames': 0,
        'gamesWinRate': 0,
        'doIplay': false,
      });
      print('Player added to Firestore successfully.');
    } catch (error) {
      print('Error adding player to Firestore: $error');
    }
  }

  // READ: get players from database sorted by name
  Stream<QuerySnapshot> getplayersStreamSortedByName() {
    final Stream<QuerySnapshot> playersStream =
        players.orderBy('name', descending: false).snapshots();
    return playersStream;
  }

  // READ: get players from database sorted by games
  Stream<QuerySnapshot> getplayersStreamSortedByGames() {
    final Stream<QuerySnapshot> playersStream =
        players.orderBy('gamesPlayed', descending: true).snapshots();
    return playersStream;
  }

  // UPDATE: update players based on name
  Future<void> updatePlayer(String playerName, int score, bool winner) async {
    try {
      // Check if the playerName is not empty or null
      if (playerName.isNotEmpty) {
        // Query Firestore to find the document where the name matches the provided playerName
        QuerySnapshot querySnapshot =
            await players.where('name', isEqualTo: playerName).get();

        // Iterate over the documents in the query snapshot
        for (var doc in querySnapshot.docs) {
          // Access the player's stats from the document data
          Map<String, dynamic> playerData = doc.data() as Map<String, dynamic>;

          // Extract the required stats from the player's data
          int currentScore = playerData['score'] ?? -100;
          int currentGamesPlayed = playerData['gamesPlayed'] ?? 0;
          int currentWinGames = playerData['winGames'] ?? 0;

          // Calculate win rate ( add +1 to currentWin if player.winner == true)
          int gamesWinRate = winner
              ? ((currentWinGames + 1) * 100) ~/ (currentGamesPlayed + 1)
              : ((currentWinGames) * 100) ~/ (currentGamesPlayed + 1);

          // Update the player's stats based on the provided data
          await doc.reference.update({
            'gamesPlayed': FieldValue.increment(1),
            'maxPoints': max(currentScore, score),
            'winGames': winner ? FieldValue.increment(1) : currentWinGames,
            'gamesWinRate': gamesWinRate,
            'doIplay': false,
          });
        }
      } else {
        print('Invalid player name.');
      }
    } catch (error) {
      print('Error updating player stats: $error');
    }
  }

  // UPDATE: update players doIplay
  Future<void> doPlayerPlay(String playerName) async {
    try {
      // Check if the playerName is not empty or null
      if (playerName.isNotEmpty) {
        // Query Firestore to find the document where the name matches the provided playerName
        QuerySnapshot querySnapshot =
            await players.where('name', isEqualTo: playerName).get();

        // Iterate over the documents in the query snapshot
        for (var doc in querySnapshot.docs) {
          // Access the player's stats from the document data
          Map<String, dynamic> playerData = doc.data() as Map<String, dynamic>;

          // Extract the required stats from the player's data
          bool currentDoIPlay = playerData['doIplay'] ?? false;

          // Update the player's do I play when we check
          await doc.reference.update({
            'doIplay': !currentDoIPlay,
          });
        }
      } else {
        print('Invalid player name.');
      }
    } catch (error) {
      print('Error updating doIplay: $error');
    }
  }

  // DELETE: delete player given a doc id
  Future<void> deletePlayer(String docID) {
    return players.doc(docID).delete();
  }
}
