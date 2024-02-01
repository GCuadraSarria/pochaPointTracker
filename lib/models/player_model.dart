class Player {
  String name;
  int? gamesPlayed;
  int? maxPoints;
  double? gamesWinRate;

  Player({
    required this.name,
    this.gamesPlayed,
    this.maxPoints,
    this.gamesWinRate,
  });
}

class PlayerInGame {
  String name;
  int score;
  int order;
  int localPoints;
  String vote;
  String baz;

  PlayerInGame({
    required this.name,
    this.score = 0,
    this.order = 0,
    this.localPoints = 0,
    this.vote = '-',
    this.baz = '-',
  });
}
