import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

class SortPlayersPage extends StatefulWidget {
  const SortPlayersPage({super.key});

  @override
  State<SortPlayersPage> createState() => _SortPlayersPageState();
}

class _SortPlayersPageState extends State<SortPlayersPage> {
  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => SafeArea(
        child: Scaffold(
          // avoids keyboard pushing bottom content
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
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 0.5,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            child:
                                Image.asset('lib/assets/icons/step_icon_2.png'),
                          ),
                        ),
                        const Text(
                          '¿En qué orden jugaréis?',
                          style: TextStyle(
                            color: CustomColors.whiteColor,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // reorderable players list
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) =>
                          currentPlayersProvider.sortCurrentPlayer(
                              oldIndex, newIndex),
                      children: [
                        for (final player
                            in currentPlayersProvider.currentPlayers)
                          ListTile(
                            key: ValueKey(player),
                            leading: const Icon(Icons.reorder),
                            title: Text(
                              player.playerName,
                              style: const TextStyle(
                                color: CustomColors.whiteColor,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // alert information box
                  Container(
                    height: 60.0,
                    width: 340.0,
                    decoration: BoxDecoration(
                      color: CustomColors.bgGradient1,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'lib/assets/icons/warning.svg',
                          semanticsLabel: 'warning icon',
                          colorFilter:
                              const ColorFilter.mode(CustomColors.secondaryColor, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 8.0),
                        const Text(
                          'Los jugadores deben organizarse en \nsentido contrario a las agujas del reloj.',
                          style: TextStyle(
                            color: CustomColors.whiteColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.clip
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // back and next buttons
                  const GoBackButton(),
                  CustomButton(
                    text: 'Ir a ver quien reparte',
                    width: 340.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DealerPlayersPage()),
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
