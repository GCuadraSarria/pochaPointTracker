import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

class PlayerSelection extends StatefulWidget {
  final String playerName;
  final bool playerDoPlay;

  const PlayerSelection({
    super.key,
    required this.playerName,
    required this.playerDoPlay,
  });

  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}

class _PlayerSelectionState extends State<PlayerSelection> {
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
              value: widget.playerDoPlay,
              onChanged: (bool? value) {
                setState(() {
                  // update doIplay bool
                  firestoreService.doPlayerPlay(widget.playerName);
                  // update button
                  currentPlayersProvider.enableButtonToSortPlayers(
                      widget.playerName, value);
                });
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
