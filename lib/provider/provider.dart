import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/models/player_model.dart';

class CurrentPlayers extends ChangeNotifier {
  List<PlayerInGame> _currentPlayers = [];
  List<PlayerInGame> get currentPlayers => _currentPlayers;

  bool _didAllPlayersVote = false;
  bool get didAllPlayersVote => _didAllPlayersVote;

  int _totalVotes = 0;
  int get totalVotes => _totalVotes;

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

    // Notify listeners
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
    //TODO: number of rounds still not dynamic, change this after that
    // check if the sum of votes is equal to the number of cards
    if (totalVotes == 6) {
      _didAllPlayersVote = false;
      notifyListeners();
      return;
    }

    _didAllPlayersVote = true;
    notifyListeners();
  }
}
