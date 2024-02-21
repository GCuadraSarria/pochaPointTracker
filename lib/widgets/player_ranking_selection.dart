import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

class PlayerRankingSelection extends StatefulWidget {
  final String playerName;
  final bool selectionRank;

  const PlayerRankingSelection({
    super.key,
    required this.playerName,
    required this.selectionRank,
  });

  @override
  State<PlayerRankingSelection> createState() => _PlayerRankingSelectionState();
}

class _PlayerRankingSelectionState extends State<PlayerRankingSelection> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => Row(
        children: [
          Transform.scale(
            scale: 1.25,
            alignment: Alignment.centerLeft,
            child: Checkbox(
              activeColor: CustomColors.secondaryColor,
              value: widget.selectionRank,
              onChanged: (bool? value) {
                setState(() {
                  // update rank check bool
                  firestoreService.playerSelection(widget.playerName, value!);
                });
              },
            ),
          ),
          const SizedBox(width: 5.0),
          Text(
            widget.playerName,
            style: const TextStyle(
              color: CustomColors.whiteColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
