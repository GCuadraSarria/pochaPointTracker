import 'package:flutter/material.dart';

class PlayerAchievementsView extends StatefulWidget {
  const PlayerAchievementsView({super.key});

  @override
  State<PlayerAchievementsView> createState() => _PlayerAchievementsViewState();
}

class _PlayerAchievementsViewState extends State<PlayerAchievementsView> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [Text('Logros de jugadores')],
    );
  }
}
