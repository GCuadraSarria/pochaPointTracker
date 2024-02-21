import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of players
  final CollectionReference players =
      FirebaseFirestore.instance.collection('players');

  // Check if a player name already exists
  Future<bool> doesPlayerExist(String playerName) async {
    final QuerySnapshot queryResult =
        await players.where('playerName', isEqualTo: playerName).limit(1).get();

    return queryResult.docs.isNotEmpty;
  }

  // CREATE: add a new player
  Future<void> addPlayer(String playerName) async {
    try {
      // Add the new player document to the "players" collection
      await players.add({
        'playerName': playerName,
        'gamesPlayed': 0,
        'winGames': 0,
        'gamesWinRate': 0,
        'doIplay': false,
        'selectionRank': true,
      });
      // ignore: avoid_print
      print('Player added to Firestore successfully.');
    } catch (error) {
      // ignore: avoid_print
      print('Error adding player to Firestore: $error');
    }
  }

  // READ: get players to show the info
  Stream<QuerySnapshot> showPlayersInfoSorted(String sortValue) {
    if (sortValue == 'playerName') {
      final Stream<QuerySnapshot> playersStream =
          players.orderBy(sortValue, descending: false).snapshots();
      return playersStream;
    } else {
      final Stream<QuerySnapshot> playersStream =
          players.orderBy(sortValue, descending: true).snapshots();
      return playersStream;
    }
  }

  // READ: get players to show the info
  Stream<QuerySnapshot> getPlayers(String sortValue) {
    if (sortValue == 'playerName') {
      final Stream<QuerySnapshot> playersStream =
          players.orderBy(sortValue, descending: false).snapshots();
      return playersStream;
    } else {
      final Stream<QuerySnapshot> playersStream =
          players.orderBy(sortValue, descending: true).snapshots();
      return playersStream;
    }
  }

  // READ: get players with selectionRank checked
  Stream<QuerySnapshot> getPlayersWithSelectionRankChecked() {
    final Stream<QuerySnapshot> playersStream =
        players.where('selectionRank', isEqualTo: true).snapshots();
    return playersStream;
  }

  // READ: get players name
  Future<List<String>> getPlayersName() async {
    List<String> playerSetList = [];
    // get players which selection is true
    QuerySnapshot querySnapshot = await players.get();
    // Iterate over the documents in the query snapshot
    for (var doc in querySnapshot.docs) {
      // Access the player's stats from the document data
      Map<String, dynamic> playerData = doc.data() as Map<String, dynamic>;

      // Extract the required stats from the player's data
      String playerName = playerData['playerName'] ?? '';

      playerSetList.add(playerName);
    }
    return playerSetList;
  }

  // READ: get players list with rank checked
  Stream<QuerySnapshot> getPlayersListWithRankChecked() {
    // get players which selection is true
    final Stream<QuerySnapshot> querySnapshot =
        players.where('selectionRank', isEqualTo: true).snapshots();

    return querySnapshot;
  }

  // READ: get number of players
  Future<int> getPlayerCount() async {
    // Get a snapshot of all documents in the collection
    QuerySnapshot snapshot = await players.get();

    // Return the number of documents in the snapshot
    return snapshot.size;
  }

  // UPDATE: update players based on name
  Future<void> updatePlayer(String playerName, int score, bool winner) async {
    try {
      // Check if the playerName is not empty or null
      if (playerName.isNotEmpty) {
        // Query Firestore to find the document where the name matches the provided playerName
        QuerySnapshot querySnapshot =
            await players.where('playerName', isEqualTo: playerName).get();

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
        // ignore: avoid_print
        print('Invalid player name.');
      }
    } catch (error) {
      // ignore: avoid_print
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
            await players.where('playerName', isEqualTo: playerName).get();

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
        // ignore: avoid_print
        print('Invalid player name.');
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error updating doIplay: $error');
    }
  }

  // UPDATE: update players selection rank
  Future<void> playerSelection(String playerName, bool value) async {
    try {
      // Check if the playerName is not empty or null
      if (playerName.isNotEmpty) {
        // Query Firestore to find the document where the name matches the provided playerName
        QuerySnapshot querySnapshot =
            await players.where('playerName', isEqualTo: playerName).get();

        // Iterate over the documents in the query snapshot
        for (var doc in querySnapshot.docs) {
          // Update the player's do I play when we check
          await doc.reference.update({
            'selectionRank': value,
          });
        }
      } else {
        // ignore: avoid_print
        print('Invalid player name.');
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error updating doIplay: $error');
    }
  }

  // UPDATE: select / unselect all
  Future<void> selectAll(bool selection) async {
    try {
      // Query Firestore to get all the documents
      QuerySnapshot querySnapshot = await players.get();

      // Iterate over the documents in the query snapshot
      for (var doc in querySnapshot.docs) {
        // Update the player's stats based on the provided data
        await doc.reference.update({'selectionRank': selection});
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error updating player stats: $error');
    }
  }

  // UPDATE: update players restart game
  Future<void> restartPlayers() async {
    try {
      // Check if the playerName is not empty or null

      // Query Firestore to find the document where the name matches the provided playerName
      QuerySnapshot querySnapshot = await players.get();

      // Iterate over the documents in the query snapshot
      for (var doc in querySnapshot.docs) {
        // Update the player's do I play when we check
        await doc.reference.update({
          'doIplay': false,
        });
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error updating doIplay: $error');
    }
  }

  // DELETE: delete player given a doc id
  Future<void> deletePlayer(String docID) {
    return players.doc(docID).delete();
  }
}
