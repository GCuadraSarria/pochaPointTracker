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
  Future<void> addPlayer(String name) {
    return players.add({
      'name': name,
      'gamesPlayed': 0,
      'maxPoints': 0,
      'gamesWinRate': 0.0,
    });
  }

  // READ: get players from database sorted by name
  Stream<QuerySnapshot> getplayersStreamSortedByName() {
    final playersStream =
        players.orderBy('name', descending: false).snapshots();
    return playersStream;
  }

  // READ: get players from database sorted by name
  Stream<QuerySnapshot> getplayersStreamSortedByGames() {
    final playersStream =
        players.orderBy('gamesPlayed', descending: true).snapshots();
    return playersStream;
  }

  // UPDATE: update player given a doc id
  Future<void> updatePlayer(String docID, String newName) {
    return players.doc(docID).update({
      'name': newName,
    });
  }

  // DELETE: delete player given a doc id
  Future<void> deletePlayer(String docID) {
    return players.doc(docID).delete();
  }
}
