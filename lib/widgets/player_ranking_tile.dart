import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

class PlayerRankingTile extends StatefulWidget {
  final String playerName;
  final int gamesPlayed;
  final int winGames;
  final double gamesWinRate;

  const PlayerRankingTile({
    super.key,
    required this.playerName,
    required this.gamesPlayed,
    required this.winGames,
    required this.gamesWinRate,
  });

  @override
  State<PlayerRankingTile> createState() => _PlayerRankingTileState();
}

class _PlayerRankingTileState extends State<PlayerRankingTile> {
// firestore service
  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CustomColors.whiteColor, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  widget.playerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${widget.gamesPlayed}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${widget.winGames}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${widget.gamesWinRate}%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
