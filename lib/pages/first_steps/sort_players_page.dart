import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/first_steps/dealer_players_page.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
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
          body: Padding(
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
                          color: Colors.white,
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
                            player.name,
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
                const Spacer(),

                // back and next buttons
                GoBackButton(),
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
    );
  }
}
