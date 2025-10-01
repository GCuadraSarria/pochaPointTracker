import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import '../../widgets/widgets.dart';

class GameDetailsPage extends StatelessWidget {
  const GameDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();

    // return cards with stats
    List<Widget> buildStatsWidget() {
      return List.generate(
        currentPlayersProvider.currentPlayers.length,
        (index) {
          final player = currentPlayersProvider.currentPlayers[index];

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
            child: Container(
              height: 60.0,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: player.winner == false
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: CustomColors.whiteColor, width: 1.5),
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
                      player.winner == false
                          ? Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                color: CustomColors.whiteColor,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w200,
                              ),
                            )
                          : SvgPicture.asset('lib/assets/images/mini_cup.svg',
                              height: 18.0,
                              width: 18.0,
                              semanticsLabel: 'mini cup'),
                      const SizedBox(width: 8.0),
                      Text(
                        player.playerName,
                        style: const TextStyle(
                          color: CustomColors.whiteColor,
                          fontSize: 22.0,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${player.score}',
                    style: const TextStyle(
                      color: CustomColors.whiteColor,
                      fontSize: 22.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => SafeArea(
        child: Scaffold(
          body: Container(
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
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Clasificación de la partida',
                      style: TextStyle(
                        color: CustomColors.whiteColor,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 56.0),
                  // show winner
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(children: buildStatsWidget()),
                        ),
                      ],
                    ),
                  ),

                  // restart and menu buttons
                  TextButton(
                    onPressed: () {
                      currentPlayersProvider.restartGame();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Volver al menú',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: CustomColors.whiteColor,
                        color: CustomColors.whiteColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CustomButton(
                    text: 'Nueva partida',
                    width: 340.0,
                    onPressed: () {
                      currentPlayersProvider.restartGame();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectPlayersPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
