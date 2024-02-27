import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

import '../models/player_model.dart';

class PlayerRankingSelection extends StatefulWidget {
  final String playerName;
  final bool selected;
  final int index;

  const PlayerRankingSelection({
    super.key,
    required this.playerName,
    required this.selected,
    required this.index,
  });

  @override
  State<PlayerRankingSelection> createState() => _PlayerRankingSelectionState();
}

class _PlayerRankingSelectionState extends State<PlayerRankingSelection> {
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
              value:
                  currentPlayersProvider.allPlayersList[widget.index].selected,
              onChanged: (bool? value) {
                setState(() {
                  currentPlayersProvider.allPlayersList[widget.index].selected =
                      value!;
                  // evaluate the button everytime we change a checkbox
                  currentPlayersProvider.setNotPlayersSelected();
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
