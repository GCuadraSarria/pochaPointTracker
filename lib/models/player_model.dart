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
  int score = 0;
  int order = 0;
  bool bazyvot = false;
  String vote;
  
  PlayerInGame({
    required this.name,
    this.score = 0,
    this.order = 0,
    this.bazyvot = false,
    this.vote = '-',
  });
}
