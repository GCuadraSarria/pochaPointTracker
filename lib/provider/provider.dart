import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/models/player_model.dart';
import 'package:pocha_points_tracker/services/firestore.dart';

// firestore service
final FirestoreService firestoreService = FirestoreService();
// get collection of players
final CollectionReference playersCollection =
    FirebaseFirestore.instance.collection('players');

// currentplayers provider
class CurrentPlayers extends ChangeNotifier {
  List<PlayerInGame> _currentPlayers = [];
  List<PlayerInGame> get currentPlayers => _currentPlayers;

  //[playerName, check]
  List<List<dynamic>> _playerCheckedList = [];
  List<List<dynamic>> get playerCheckedList => _playerCheckedList;

  bool _isButtonDisabled = true;
  bool get isButtonDisabled => _isButtonDisabled;

  bool _didAllPlayersVote = false;
  bool get didAllPlayersVote => _didAllPlayersVote;

  bool _didAllPlayersBaz = false;
  bool get didAllPlayersBaz => _didAllPlayersBaz;

  int _totalVotes = 0;
  int get totalVotes => _totalVotes;

  int _totalBaz = 0;
  int get totalBaz => _totalBaz;

  String _sortingRank = 'gamesPlayed';
  String get sortingRank => _sortingRank;

  List<String> _scrollableNumberList = ['-', '0', '1'];
  List<String> get scrollableNumberList => _scrollableNumberList;

  bool _wePlayIndia = true;
  bool get wePlayIndia => _wePlayIndia;

  bool _lastRound = false;
  bool get lastRound => _lastRound;

  int _round = 1;
  int get round => _round;

  int _maxCards = 7;
  int get maxCards => _maxCards;

  int _numberOfCards = 1;
  int get numberOfCards => _numberOfCards;

  bool _dealerFlag = false;
  bool get dealerFlag => _dealerFlag;

  int _totalPlayersFilter = 0;
  int get totalPlayersFilter => _totalPlayersFilter;


  // add a player to the new game
  Future<void> addPlayers() async {
    // we filter all players where doIplay is set to true
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('players')
              .where('doIplay', isEqualTo: true)
              .get();
      // we loop in the document and add everyname filtered to _currentPlayers
      for (var doc in querySnapshot.docs) {
        _currentPlayers.add(PlayerInGame(playerName: doc['playerName']));
        notifyListeners();
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error getting players playing: $error');
    }
  }

  // sort players based on the drag and drop
  void sortCurrentPlayer(int oldIndex, int newIndex) {
    // adjust if the tile goes to the bottom
    if (oldIndex < newIndex) {
      newIndex--;
    }

    // Create a copy of the current players list
    List<PlayerInGame> updatedPlayers = List.from(_currentPlayers);

    // Move the player to the new position
    final PlayerInGame player = updatedPlayers.removeAt(oldIndex);
    updatedPlayers.insert(newIndex, player);

    // Update the _currentPlayers list
    _currentPlayers = updatedPlayers;

    notifyListeners();
  }

  // get number of players filtered
  void filteredPlayers(int amountFiltered) {
    _totalPlayersFilter = amountFiltered;
    notifyListeners();
  }

  // sort players by score
  void sortByScore() {
    _currentPlayers = _currentPlayers.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    notifyListeners();
  }

  // sort players based on the dealer
  void sortByMatch(String dealerName) {
    // if the dealer is not the last in the list we sort it
    if (_currentPlayers.last.playerName != dealerName) {
      int indexPlayer = _currentPlayers
          .indexWhere((player) => player.playerName == dealerName);

      // Sort the list, moving the specified string to the end
      // if the dealer is not already the last player in the list

      _currentPlayers = _currentPlayers.sublist(indexPlayer + 1)
        ..addAll(_currentPlayers.sublist(0, indexPlayer + 1));
    }

    for (var i = 0; i < _currentPlayers.length; i++) {
      _currentPlayers[i].order = i;
    }
    notifyListeners();
  }

  // enable button
  void enableButtonToSortPlayers(String playerName, bool? check) {
    // loop thru the list to check the existences
    bool playerExists = false;
    for (var player in playerCheckedList) {
      // if the player exists, update the check value
      if (player[0] == playerName) {
        player[1] = check;
        playerExists = true;
        break; // exit loop once player is found
      }
    }

    // if the player doesn't exist, add it with the check
    if (!playerExists) {
      playerCheckedList.add([playerName, check]);
    }
    // we count the amounts of true
    int count = 0;
    for (var player in playerCheckedList) {
      if (player.length > 1 && player[1] == true) {
        count++;
      }
    }
    _isButtonDisabled = count < 2;

    notifyListeners();
  }

  // enable button after dealer
  void gotDealer() {
    _dealerFlag = true;
    notifyListeners();
  }

  // set max cards to play with
  void setMaxCards(int maxCardsSelected) {
    _maxCards = maxCardsSelected;
    notifyListeners();
  }

  // set if we play india
  void setPlayWithIndia(bool? playWithIndiaSelected) {
    if (playWithIndiaSelected != null) _wePlayIndia = playWithIndiaSelected;
    notifyListeners();
  }

  // set sorting value in ranking page
  void setSortingRank(String sortValue) {
    _sortingRank = sortValue;
    notifyListeners();
  }

  // check if all players voted
  void checkIfAllPlayersVoted() {
    int totalVotes = 0;

    // check if any player has not voted -> '-'
    for (int i = 0; i < currentPlayers.length; i++) {
      if (currentPlayers[i].vote == '-') {
        _didAllPlayersVote = false;
        notifyListeners();
        return;
      }
      totalVotes += int.parse(currentPlayers[i].vote);
    }
    // check if the sum of votes is equal to the number of cards
    if (totalVotes == _numberOfCards) {
      _didAllPlayersVote = false;
      notifyListeners();
      return;
    }

    _didAllPlayersVote = true;
    notifyListeners();
  }

  // check if all players added the baz
  void checkIfAllPlayersBaz() {
    int totalBaz = 0;

    // check if any player has not voted -> '-'
    for (int i = 0; i < currentPlayers.length; i++) {
      if (currentPlayers[i].baz == '-') {
        _didAllPlayersBaz = false;
        notifyListeners();
        return;
      }
      totalBaz += int.parse(currentPlayers[i].baz);
    }
    // check if the sum of baz is equal to the number of cards
    if (totalBaz != _numberOfCards) {
      _didAllPlayersBaz = false;
      notifyListeners();
      return;
    }

    _didAllPlayersBaz = true;
    notifyListeners();
  }

  // next round
  void nextRound() {
    _round++;

    // if the round and the max cards match we skip adding or removing
    // in round X and X + 1 we play X cards
    if ((_maxCards + 1) == _round) {
      // if we are in the last round and we play india we add another round and set lastRound = true
    } else if (_wePlayIndia == true && (_maxCards * 2 + 1) == _round) {
      _lastRound = true;
      _numberOfCards = 1;

      // if we are in the last round and we play india we add another round and set lastRound = true
    } else if (_wePlayIndia == false && _maxCards * 2 == _round) {
      _lastRound = true;
      removeCardsToTheRound();

      // if max cards are smaller than the round that means we are ahead of half of the game
    } else if (_maxCards < _round) {
      removeCardsToTheRound();

      // in the rest of cases we just add cards
    } else {
      addCardsToTheRound();
    }

    // a new list of cards shall generate
    generateScrollableLists();

    // clean the vote and baz provider
    _totalVotes = 0;
    _totalBaz = 0;

    // clean the total voz and baz provider
    _didAllPlayersVote = false;
    _didAllPlayersBaz = false;

    // we have to update the score of the players
    // we have to clean the players localpoints, vote and baz to 0
    for (int i = 0; i < _currentPlayers.length; i++) {
      // we add the new points to the current score
      _currentPlayers[i].score += _currentPlayers[i].localPoints;
      _currentPlayers[i].localPoints = 0;
      _currentPlayers[i].vote = '-';
      _currentPlayers[i].baz = '-';
    }

    // we have to sort the players moving everyone upwards, the current
    //index 0 gets the last index because he becomes the dealer
    sortByMatch(_currentPlayers.first.playerName);
    notifyListeners();
  }

  // check player points after a vote or baz
  void checkPlayerPoints(String currentPlayer) {
    int playerIndex = _currentPlayers
        .indexWhere((player) => player.playerName == currentPlayer);

    // if the current player voted and baz we calculate the points
    if (_currentPlayers[playerIndex].vote != '-' &&
        _currentPlayers[playerIndex].baz != '-') {
      // we get points if vote = baz
      // 10 points for win + 5 extra points per baz earned
      if (_currentPlayers[playerIndex].vote ==
          _currentPlayers[playerIndex].baz) {
        _currentPlayers[playerIndex].localPoints =
            10 + 5 * int.parse(_currentPlayers[playerIndex].baz);
      }
      // we lose points if vote != baz
      // -5 points for every difference between them
      else {
        _currentPlayers[playerIndex].localPoints = -5 *
            (int.parse(_currentPlayers[playerIndex].vote) -
                    int.parse(_currentPlayers[playerIndex].baz))
                .abs();
      }
    } else {
      _currentPlayers[playerIndex].localPoints = 0;
    }
    notifyListeners();
  }

  // add cards to the next round
  void addCardsToTheRound() {
    _numberOfCards++;
    notifyListeners();
  }

  // remove cards to the next round
  void removeCardsToTheRound() {
    _numberOfCards--;
    notifyListeners();
  }

  // generate list of scrollable numbers based on number of cards + '-'
  void generateScrollableLists() {
    _scrollableNumberList =
        List.generate(_numberOfCards + 1, (index) => index.toString());
    _scrollableNumberList.insert(0, '-');
    notifyListeners();
  }

  // finish game, check winner
  void finishGame() {
    for (int i = 0; i < _currentPlayers.length; i++) {
      // we add the new points to the current score
      _currentPlayers[i].score += _currentPlayers[i].localPoints;
    }
    // sort the players by score
    sortByScore();

    // set the first player as the winner
    _currentPlayers.first.winner = true;

    // set the rest of the players with the same score as the winner as winners
    _currentPlayers
        .skip(1)
        .where((player) => player.score == _currentPlayers.first.score)
        .forEach((player) => player.winner = true);

    // we have to update the score of the players
    // we have to clean the players localpoints, vote and baz to 0
    for (int i = 0; i < _currentPlayers.length; i++) {
      _currentPlayers[i].localPoints = 0;
      _currentPlayers[i].vote = '-';
      _currentPlayers[i].baz = '-';
      // update player by player values
      firestoreService.updatePlayer(_currentPlayers[i].playerName,
          _currentPlayers[i].score, _currentPlayers[i].winner);
      firestoreService.restartPlayers();
    }
    notifyListeners();
  }

  // restart game, default values
  void restartGame() {
    _currentPlayers = [];
    _scrollableNumberList = ['-', '0', '1'];
    _playerCheckedList = [];
    _isButtonDisabled = true;
    _didAllPlayersVote = false;
    _didAllPlayersBaz = false;
    _totalVotes = 0;
    _totalBaz = 0;
    _sortingRank = 'playerName';
    _lastRound = false;
    _round = 1;
    _numberOfCards = 1;
    _lastRound = false;
    _dealerFlag = false;
    notifyListeners();
  }
}
