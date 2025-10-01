import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocha_points_tracker/models/models.dart';

class FirestoreService {
  // get collection of players
  final CollectionReference players =
      FirebaseFirestore.instance.collection('players');

  // get collection of games
  final CollectionReference games =
      FirebaseFirestore.instance.collection('games');

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
      });
      // ignore: avoid_print
      print('Player added to Firestore successfully.');
    } catch (error) {
      // ignore: avoid_print
      print('Error adding player to Firestore: $error');
    }
  }

  // CREATE: add a new game after finishing it
  Future<String> addGame(List<String> playerNames) async {
    // Add the last game to the "games" collection
    DocumentReference docRef = await games.add({
      'startDate': DateTime.now(),
      'status': 'active',
      'players': playerNames,
      'dealer': playerNames.last,
    });
    return docRef.id;
  }

  // UPDATE: update players sorted by score
  Future<void> updatePlayersArray(String gameId, List<String> players) async {
    final docRef = games.doc(gameId);
    await docRef.update({'players': players});
  }

  // UPDATE: update the game with the end date
  Future<void> updateGame(
    String gameId, {
    List<String>? players,
    List<String>? winners,
    Map<String, int>? scores,
    Map<String, List<int>>? totalScore,
    Map<String, List<String>>? bazas,
    Map<String, List<String>>? votos,
    Map<String, String>? currentVotes,
    Map<String, String>? currentBazas,
    String? status,
    int? round,
  }) async {
    await games.doc(gameId).update({
      if (players != null && players.isNotEmpty) 'players': players,
      if (winners != null && winners.isNotEmpty) 'winner': winners,
      if (scores != null) 'scores': scores,
      if (totalScore != null) 'totalScore': totalScore,
      if (bazas != null) 'bazas': bazas,
      if (votos != null) 'votos': votos,
      if (round != null) 'round': round,
      if (status != null) 'status': status,
      if (currentVotes != null) 'currentVotes': currentVotes,
      if (currentBazas != null) 'currentBazas': currentBazas,
      'endDate': DateTime.now(),
    });
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

  // READ: get games to show the info
  Stream<QuerySnapshot> getGamesStream() {
    return games
        .orderBy('startDate', descending: true)
        .where('status', isEqualTo: 'finished')
        .snapshots();
  }

  // READ: get current games to show the info
  Stream<QuerySnapshot> getCurrentGamesStream() {
    return games
        .orderBy('startDate', descending: true)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  // READ: get players to show the info where the checkbox is true
  Stream<QuerySnapshot> getPlayersSorted(
      String sortValue, List<PlayerInRank> allPlayersList) {
    // Filter the allPlayersList to get only the players with selected == true
    List<PlayerInRank> selectedPlayers =
        allPlayersList.where((player) => player.selected).toList();

    if (selectedPlayers.isEmpty) {
      // Devuelve un stream vacío para evitar el error de Firestore
      return const Stream.empty();
    }
    // Construct a list of player names
    List<String> selectedPlayerNames =
        selectedPlayers.map((player) => player.playerName).toList();

    // Construct a query for players whose names are in selectedPlayerNames
    Query query = players.where('playerName', whereIn: selectedPlayerNames);

    // Order the query based on the sortValue
    if (sortValue == 'playerName' || sortValue == 'minPoints') {
      query = query.orderBy(sortValue, descending: false);
    } else {
      query = query.orderBy(sortValue, descending: true);
    }
    print(
        'FirestoreService.getPlayersSorted recibe: ${selectedPlayers.map((p) => p.playerName).toList()}');

    // Return the snapshots stream of the constructed query
    return query.snapshots();
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

  // READ: get number of players
  Future<int> getPlayerCount() async {
    // Get a snapshot of all documents in the collection
    QuerySnapshot snapshot = await players.get();

    // Return the number of documents in the snapshot
    return snapshot.size;
  }

  // READ: get games by players
  Stream<QuerySnapshot> getGamesByExactPlayers(List<String> playerNames) {
    // Si la lista está vacía, devuelve todas las partidas
    if (playerNames.isEmpty) {
      return games
          .orderBy('startDate', descending: true)
          .where('status', isEqualTo: 'finished')
          .snapshots();
    }
    // arrayContainsAny solo permite hasta 10 elementos
    return games
        .where('players', arrayContainsAny: playerNames)
        .where('status', isEqualTo: 'finished')
        .orderBy('startDate', descending: true)
        .snapshots();
  }

  // UPDATE: update players vote live
  Future<void> updatePlayerCurrentVote(
      String gameId, String playerName, String vote) async {
    await games.doc(gameId).update({'currentVotes.$playerName': vote});
  }

  // UPDATE: update players baz live
  Future<void> updatePlayerCurrentBaz(
      String gameId, String playerName, String baz) async {
    await games.doc(gameId).update({'currentBazas.$playerName': baz});
  }

  // UPDATE: update dealer
  Future<void> updateDealer(String gameId, String dealer) async {
    await games.doc(gameId).update({'dealer': dealer});
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
          int currentMaxPoints = playerData['maxPoints'] ?? -100;
          int currentGamesPlayed = playerData['gamesPlayed'] ?? 0;
          int currentWinGames = playerData['winGames'] ?? 0;
          int currentMinPoints = playerData['minPoints'] ?? 100;

          // Calculate win rate ( add +1 to currentWin if player.winner == true)
          int gamesWinRate = winner
              ? ((currentWinGames + 1) * 100) ~/ (currentGamesPlayed + 1)
              : ((currentWinGames) * 100) ~/ (currentGamesPlayed + 1);

          // Update the player's stats based on the provided data
          await doc.reference.update({
            'gamesPlayed': FieldValue.increment(1),
            'maxPoints': max(currentMaxPoints, score),
            'minPoints': min(currentMinPoints, score),
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
