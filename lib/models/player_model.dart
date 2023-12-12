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
