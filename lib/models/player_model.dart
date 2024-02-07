class PlayerInGame {
  String name;
  int score;
  int currentWinGames;
  int order;
  int localPoints;
  String vote;
  String baz;
  bool winner;

  PlayerInGame({
    required this.name,
    this.score = 0,
    this.currentWinGames = 0,
    this.order = 0,
    this.localPoints = 0,
    this.vote = '-',
    this.baz = '-',
    this.winner = false,
  });
}
