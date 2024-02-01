import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/models/player_model.dart';

class CurrentPlayers extends ChangeNotifier {
  List<PlayerInGame> _currentPlayers = [];
  List<PlayerInGame> get currentPlayers => _currentPlayers;

  bool _didAllPlayersVote = false;
  bool get didAllPlayersVote => _didAllPlayersVote;

  bool _didAllPlayersBaz = false;
  bool get didAllPlayersBaz => _didAllPlayersBaz;

  int _totalVotes = 0;
  int get totalVotes => _totalVotes;

  int _totalBaz = 0;
  int get totalBaz => _totalBaz;

  List<String> _scrollableNumberList = ['-', '0', '1'];
  List<String> get scrollableNumberList => _scrollableNumberList;

  int _round = 1;
  int get round => _round;

  final int _maxCards = 4;
  int get maxCards => _maxCards;

  int _numberOfCards = 1;
  int get numberOfCards => _numberOfCards;

  // add a player to the new game
  void addCurrentPlayer(String playerName) {
    _currentPlayers.add(PlayerInGame(name: playerName));
    notifyListeners();
  }

  // remove a player from the new game
  void removeCurrentPlayer(String playerName) {
    _currentPlayers.removeWhere((player) => player.name == playerName);
    notifyListeners();
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

  // sort players based on the dealer
  void sortByMatch(int indexPlayer) {
    // Sort the list, moving the specified string to the end
    // if the dealer is not already the last player in the list
    if (_currentPlayers.length - 1 != indexPlayer) {
      _currentPlayers = _currentPlayers.sublist(indexPlayer + 1)
        ..addAll(_currentPlayers.sublist(0, indexPlayer + 1));
    }

    for (var i = 0; i < _currentPlayers.length; i++) {
      _currentPlayers[i].order = i;
    }
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
    if ((_maxCards + 1) == round) {
      // if we are in the last round (max cards * 2 + 1) and we are playing
      // with india, we play with just 1 card
      //TODO: add india
    } else if ((_maxCards * 2 + 1) == round) {
      _numberOfCards = 1;
      finishGame();
      // if max cards are smaller than the round that means we are ahead of half of the game
    } else if (_maxCards < round) {
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
    sortByMatch(0);
    notifyListeners();
  }

  // check player points after a vote or baz
  void checkPlayerPoints(String currentPlayer) {
    int playerIndex =
        _currentPlayers.indexWhere((player) => player.name == currentPlayer);

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

  // finish game, check winner, add stats to firebase
  void finishGame() {
    print('Game finished');
    notifyListeners();
  }
}
