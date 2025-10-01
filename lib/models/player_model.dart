class PlayerInGame {
  String playerName;
  int score;
  List<int> totalScore;
  int currentWinGames;
  int order;
  int localPoints;
  String vote;
  String baz;
  bool winner;
  List<String> bazList;
  List<String> voteList;

  PlayerInGame({
    required this.playerName,
    this.score = 0,
    List<int>? totalScore,
    this.currentWinGames = 0,
    this.order = 0,
    this.localPoints = 0,
    this.vote = '-',
    this.baz = '-',
    this.winner = false,
    List<String>? bazList,
    List<String>? voteList,
  })  : totalScore = totalScore ?? [],
        bazList = bazList ?? [],
        voteList = voteList ?? [];
}

class PlayerInRank {
  String playerName;
  bool selected;

  PlayerInRank({
    required this.playerName,
    this.selected = true,
  });
}
