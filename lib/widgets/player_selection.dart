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
    final isSelected = widget.playerDoPlay;

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => GestureDetector(
        onTap: () {
          setState(() {
            firestoreService.doPlayerPlay(widget.playerName);
            currentPlayersProvider.enableButtonToSortPlayers(
                widget.playerName, !isSelected);
          });
        },
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? CustomColors.secondaryColor.withAlpha(90)
                      : Colors.transparent,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
