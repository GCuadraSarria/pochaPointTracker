import 'package:flutter/material.dart';

class CurrentPlayers extends ChangeNotifier {
  final List<String> _currentPlayers = [];

  List<String> get currentPlayers => _currentPlayers;

  // add a player to the new game
  void addCurrentPlayer(String player) {
    _currentPlayers.add(player);
    notifyListeners();
  }

  // remove a player from the new game
  void removeCurrentPlayer(String player) {
    _currentPlayers.remove(player);
    notifyListeners();
  }

  // sort players based on the drag and drop
  void sortCurrentPlayer(int oldIndex, int newIndex) {
    // adjust if the tile goes to the bottom
    if (oldIndex < newIndex) {
      newIndex--;
    }

    // get the tile we are moving
    final player = _currentPlayers.removeAt(oldIndex);

    // place the tile in the new position
    _currentPlayers.insert(newIndex, player);

    notifyListeners();
  }

  // sort players based on the dealer
  void sortByMatch(String dealerPlayer) {
    // Sort the list, moving the specified string to the end
    _currentPlayers.sort((a, b) {
      if (a == dealerPlayer) {
        return 1; // Move 'matchString' to the end
      } else if (b == dealerPlayer) {
        return -1; // Move 'matchString' to the end
      } else {
        return a.compareTo(b); // Keep the order of other elements
      }
    });
    notifyListeners();
    print('Holiwi $_currentPlayers');

    // hay que crear un objeto para preparar la nueva partida:

//Player(name: 'Peke', score: 0, order: 0, bazyvot: false, points: 0),
  }
}
