import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';

class PlayerRankingTile extends StatefulWidget {
  final int index;
  final String playerName;
  final dynamic sortingInformation;

  const PlayerRankingTile({
    super.key,
    required this.index,
    required this.playerName,
    required this.sortingInformation,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
      child: Container(
        height: 60.0,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: widget.index != 0
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: CustomColors.whiteColor, width: 1.5),
              )
            : BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    CustomColors.primaryColor,
                    CustomColors.secondaryColor,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                widget.index != 0
                    ? Text(
                        '#${widget.index + 1}',
                        style: const TextStyle(
                          color: CustomColors.whiteColor,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w200,
                        ),
                      )
                    : SvgPicture.asset('lib/assets/images/mini_cup.svg',
                        height: 18.0, width: 18.0, semanticsLabel: 'mini cup'),
                const SizedBox(width: 8.0),
                Text(
                  widget.playerName,
                  style: const TextStyle(
                    color: CustomColors.whiteColor,
                    fontSize: 22.0,
                  ),
                ),
              ],
            ),
            Text(
              '${widget.sortingInformation}',
              style: const TextStyle(
                color: CustomColors.whiteColor,
                fontSize: 22.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
