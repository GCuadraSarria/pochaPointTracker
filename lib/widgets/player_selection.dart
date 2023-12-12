import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

class PlayerSelection extends StatefulWidget {
  final String playerName;

  const PlayerSelection({
    super.key,
    required this.playerName,
  });

  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}

class _PlayerSelectionState extends State<PlayerSelection> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => Row(
        children: [
          Transform.scale(
            scale: 1.25,
            alignment: Alignment.centerLeft,
            child: Checkbox(
              activeColor: CustomColors.secondaryColor,
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
                final currentPlayers = context.read<CurrentPlayers>();
                isChecked
                    ? currentPlayers.addCurrentPlayer(widget.playerName)
                    : currentPlayers.removeCurrentPlayer(widget.playerName);
              },
            ),
          ),
          Text(
            widget.playerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
