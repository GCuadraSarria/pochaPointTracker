import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WinnerGameplayPage extends StatefulWidget {
  const WinnerGameplayPage({super.key});

  @override
  State<WinnerGameplayPage> createState() => _WinnerGameplayPageState();
}

class _WinnerGameplayPageState extends State<WinnerGameplayPage> {
  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();

    // return text or multiple text widgets of winner
    List<Widget> buildWinnerWidgets() {
      currentPlayersProvider.sortByScore();
      final List<String> winnerList = [];
      for (var player in currentPlayersProvider.currentPlayers) {
        if (player.winner == true) {
          winnerList.add(player.playerName);
        }
      }

      List<Widget> winnerTextWidgets = [];
      for (String winner in winnerList) {
        winnerTextWidgets.add(
          Text(
            '$winner wins',
            style: const TextStyle(
              color: CustomColors.whiteColor,
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              shadows: [
                Shadow(
                  color: CustomColors.backgroundColor,
                  blurRadius: 3.0,
                  offset: Offset(5.0, 5.0),
                ),
              ],
            ),
          ),
        );
      }
      return winnerTextWidgets;
    }

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => SafeArea(
        child: Scaffold(
          body: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GameDetailsPage()),
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color.fromARGB(255, 54, 18, 77),
                    CustomColors.backgroundColor
                  ],
                  stops: [
                    0.0,
                    0.9,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // show winner
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                    'lib/assets/images/winning_cup.svg',
                                    semanticsLabel: 'winning cup'),
                                const SizedBox(height: 15),
                                // we get all the currentplayers.winner = true
                                Column(children: buildWinnerWidgets()),
                                const SizedBox(height: 15),
                                Text(
                                  '${currentPlayersProvider.currentPlayers.first.score} puntos',
                                  style: const TextStyle(
                                    color: CustomColors.whiteColor,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w100,
                                    shadows: [
                                      Shadow(
                                        color: CustomColors.backgroundColor,
                                        blurRadius: 3.0,
                                        offset: Offset(5.0, 5.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
