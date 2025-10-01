import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/models/models.dart';
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

  // get game id
  String? _gameId;
  String? get gameId => _gameId;

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

  bool _selectedAllSort = true;
  bool get selectedAllSort => _selectedAllSort;

  List<PlayerInRank> _allPlayersList = [];
  List<PlayerInRank> get allPlayersList => _allPlayersList;

  bool _notPlayersSelected = false;
  bool get notPlayersSelected => _notPlayersSelected;

  bool _openRankDropdown = false;
  bool get openRankDropdown => _openRankDropdown;

  bool _showAchievement = false;
  bool get showAchievement => _showAchievement;

  String _achievementPlayer = "";
  String get achievementPlayer => _achievementPlayer;

  String _achievementName = "";
  String get achievementName => _achievementName;

  String _achievementDescription = "";
  String get achievementDescription => _achievementDescription;

  List<SortLabelDropdown> _dropdownValues = [
    SortLabelDropdown(
      label: 'Partidas jugadas',
      value: 'gamesPlayed',
    ),
    SortLabelDropdown(
      label: 'Partidas ganadas',
      value: 'winGames',
    ),
    SortLabelDropdown(
      label: 'Porcentaje de victorias',
      value: 'gamesWinRate',
    ),
    SortLabelDropdown(
      label: 'Puntuación máxima',
      value: 'maxPoints',
    ),
    SortLabelDropdown(
      label: 'Puntuación mínima',
      value: 'minPoints',
    ),
  ];
  List<SortLabelDropdown> get dropdownValues => _dropdownValues;

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

  // add all players to selected list
  Future<void> setAllPlayersList() async {
    try {
      _allPlayersList.clear();
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('players').get();
      // we loop in the document and add everyname filtered to _allPlayersList
      for (var doc in querySnapshot.docs) {
        if (!_allPlayersList
            .any((player) => player.playerName == doc['playerName'])) {
          // if the player is not in the current list we add it
          _allPlayersList.add(PlayerInRank(playerName: doc['playerName']));
        }
        notifyListeners();
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error getting players playing: $error');
    }
  }

  // apply stored list to allPlayers to discard changes
  void applyLocalList(List<PlayerInRank> value) {
    _allPlayersList = value;
    notifyListeners();
  }

  // we swap the select / unselect all
  void swapSelectAll() {
    _selectedAllSort = !_selectedAllSort;
    for (var player in _allPlayersList) {
      player.selected = _selectedAllSort;
    }

    notifyListeners();
  }

  // set open rank dropdown
  void setOpenRankDropdown(bool value) {
    _openRankDropdown = value;
    notifyListeners();
  }

  // set dropdown values
  void setDropdownValues(String value) {
    // we set all the values and then remove the selected one
    _dropdownValues = [
      SortLabelDropdown(
        label: 'Partidas jugadas',
        value: 'gamesPlayed',
      ),
      SortLabelDropdown(
        label: 'Partidas ganadas',
        value: 'winGames',
      ),
      SortLabelDropdown(
        label: 'Porcentaje de victorias',
        value: 'gamesWinRate',
      ),
      SortLabelDropdown(
        label: 'Puntuación máxima',
        value: 'maxPoints',
      ),
      SortLabelDropdown(
        label: 'Puntuación mínima',
        value: 'minPoints',
      ),
    ];
    _dropdownValues.removeWhere((dropdown) => dropdown.value == value);
    notifyListeners();
  }

  // update rank button
  void setNotPlayersSelected() {
    // if every player selected a checkbox we sent true
    _notPlayersSelected = _allPlayersList.every((player) => !player.selected);
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

  // sort players by score
  void sortByScore() {
    _currentPlayers = _currentPlayers.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    // Actualiza el array de nombres en Firestore
    if (_gameId != null) {
      final playerNames = _currentPlayers.map((p) => p.playerName).toList();
      firestoreService.updatePlayersArray(_gameId!, playerNames);
    }
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

  // enable button in sorting players page
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

  // enable button after dealer is set
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

// Adds game to firebase when game starts
  Future<void> startGame() async {
    List<String> playerNames =
        _currentPlayers.map((p) => p.playerName).toList();
    _gameId = await firestoreService.addGame(playerNames);
    notifyListeners();
  }

  // Update game data in firebase
  Future<void> updateGameData() async {
    if (_gameId == null) return;

    List<String> winners = _currentPlayers
        .where((p) => p.winner)
        .map((p) => p.playerName)
        .toList();
    Map<String, int> scores = {
      for (var p in _currentPlayers) p.playerName: p.score
    };
    Map<String, List<int>> totalScore = {
      for (var p in _currentPlayers) p.playerName: p.totalScore
    };
    Map<String, List<String>> bazas = {
      for (var p in _currentPlayers) p.playerName: p.bazList
    };
    Map<String, List<String>> votos = {
      for (var p in _currentPlayers) p.playerName: p.voteList
    };
    Map<String, String> currentVotes = {
      for (var p in _currentPlayers) p.playerName: '-'
    };
    Map<String, String> currentBazas = {
      for (var p in _currentPlayers) p.playerName: '-'
    };

    await firestoreService.updateGame(
      _gameId!,
      winners: winners,
      scores: scores,
      totalScore: totalScore,
      bazas: bazas,
      votos: votos,
      round: _round,
      currentVotes: currentVotes,
      currentBazas: currentBazas,
    );
  }

  // Añade o actualiza el voto de un jugador en la ronda actual
  Future<void> updatePlayerCurrentVote(String playerName, String vote) async {
    final player =
        _currentPlayers.firstWhere((p) => p.playerName == playerName);
    player.vote = vote;
    notifyListeners();
    if (_gameId != null) {
      await firestoreService.updatePlayerCurrentVote(
          _gameId!, playerName, vote);
    }
  }

  // Añade o actualiza el baz de un jugador en la ronda actual
  Future<void> updatePlayerCurrentBaz(String playerName, String baz) async {
    final player =
        _currentPlayers.firstWhere((p) => p.playerName == playerName);
    player.baz = baz;
    notifyListeners();
    if (_gameId != null) {
      await firestoreService.updatePlayerCurrentBaz(_gameId!, playerName, baz);
    }
  }

  // Actualiza el dealer
  Future<void> updateDealer() async {
    final dealer = _currentPlayers.last.playerName;
    if (_gameId != null) {
      await firestoreService.updateDealer(_gameId!, dealer);
    }
  }

  void clearSelectedPlayers() {
    for (var player in allPlayersList) {
      player.selected = false;
    }
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
      _currentPlayers[i].totalScore.add(_currentPlayers[i].score);
      _currentPlayers[i].bazList.add(_currentPlayers[i].baz);
      _currentPlayers[i].voteList.add(_currentPlayers[i].vote);
      _currentPlayers[i].baz == _currentPlayers[i].vote
          ? _currentPlayers[i].streak++
          : _currentPlayers[i].streak = 0;
      _currentPlayers[i].vote = '-';
      _currentPlayers[i].baz = '-';
    }
    updateGameData();

    // we have to sort the players moving everyone upwards, the current
    //index 0 gets the last index because he becomes the dealer
    sortByMatch(_currentPlayers.first.playerName);
    updateDealer();
    if (_currentPlayers.length >= 3) checkAchievements();
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
  void finishGame() async {
    for (int i = 0; i < _currentPlayers.length; i++) {
      // we add the new points to the current score
      _currentPlayers[i].score += _currentPlayers[i].localPoints;
      _currentPlayers[i].totalScore.add(_currentPlayers[i].score);
      _currentPlayers[i].bazList.add(_currentPlayers[i].baz);
      _currentPlayers[i].voteList.add(_currentPlayers[i].vote);
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

    // update the game to the games collection with the player values
    updateGameData();
    await firestoreService.updateGame(
      _gameId!,
      status: 'finished',
      players: _currentPlayers.map((p) => p.playerName).toList(),
    );

    // check achievements
    if (_currentPlayers.length >= 3) checkAchievementsPoints();

    // we have to update the score of the players
    // we have to clean the players localpoints, vote and baz to 0
    for (int i = 0; i < _currentPlayers.length; i++) {
      _currentPlayers[i].localPoints = 0;
      _currentPlayers[i].vote = '-';
      _currentPlayers[i].baz = '-';
      _currentPlayers[i].totalScore = [];
      _currentPlayers[i].bazList = [];
      _currentPlayers[i].voteList = [];
      // update player by player values
      firestoreService.updatePlayer(_currentPlayers[i].playerName,
          _currentPlayers[i].score, _currentPlayers[i].winner);
      firestoreService.restartPlayers();
    }
    notifyListeners();
  }

// seleccionamos todos los jugadores
  void selectAllPlayers() {
    for (var player in allPlayersList) {
      player.selected = true;
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
    _openRankDropdown = false;
    notifyListeners();
  }

  void checkAchievements() {
    checkAchievementsRounds();
    checkAchievementsSevenBaz();
    notifyListeners();
  }

  void checkAchievementsRounds() async {
    for (int i = 0; i < _currentPlayers.length; i++) {
      if (_currentPlayers[i].streak == 10) {
        final nuevo = await firestoreService.achievement(
            achievementId: 'racha_10',
            playerName: _currentPlayers[i].playerName);
        if (nuevo) {
          _showAchievement = true;
          _achievementPlayer = _currentPlayers[i].playerName;
          _achievementName = "Richi 10 rachas";
          _achievementDescription = "Racha de 10 bazas";
        }
        notifyListeners();
      }
    }
  }

  void checkAchievementsSevenBaz() async {
    for (int i = 0; i < _currentPlayers.length; i++) {
      if (_currentPlayers[i].bazList.last == '1' &&
          _currentPlayers[i].voteList.last == '1') {
        final nuevo = await firestoreService.achievement(
            achievementId: 'bazas_7',
            playerName: _currentPlayers[i].playerName);
        if (nuevo) {
          _achievementPlayer = _currentPlayers[i].playerName;
          _achievementName = "All-in al 7";
          _achievementDescription = "45 puntos en una ronda";
          _showAchievement = true;
        }
        notifyListeners();
      }
    }
  }

  void checkAchievementsPoints() async {
    for (int i = 0; i < _currentPlayers.length; i++) {
      if (_currentPlayers[i].score >= 200) {
        final nuevo = await firestoreService.achievement(
            achievementId: 'score_200',
            playerName: _currentPlayers[i].playerName);
        if (nuevo) {
          _achievementPlayer = _currentPlayers[i].playerName;
          _achievementName = "Mister 200%";
          _achievementDescription = "200 puntos en una partida";
          _showAchievement = true;
        }
        notifyListeners();
      }
    }
  }

  void resetAchievementOverlay() {
    _showAchievement = false;
    _achievementPlayer = "";
    _achievementName = "";
    _achievementDescription = "";
    notifyListeners();
  }
}
