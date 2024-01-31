// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/models/player_model.dart';
import 'package:provider/provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';

class GameplayPage extends StatefulWidget {
  const GameplayPage({super.key});

  @override
  State<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends State<GameplayPage> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  // sort by name / points
  late bool sortByName = true;

  // new player alertbox
  Future<String?> newPlayerAlertbox(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => const NewPlayerAlertbox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ronda 2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_vert,
                          size: 32.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      const Text(
                        '2 cartas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        ' | ',
                        style: TextStyle(
                          color: CustomColors.primaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Reparte: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currentPlayersProvider.currentPlayers.last.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                const Divider(
                  thickness: 1.5,
                  color: CustomColors.primaryColor,
                ),
                const SizedBox(height: 16.0),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(
                        'Apuestas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Containers of each player
                Expanded(
                  child: ListView.builder(
                      itemCount: currentPlayersProvider.currentPlayers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: PlayerBetContainer(playerIndex: index),
                        );
                      }),
                ),
                // back and next buttons
                const GoBackButton(),
                CustomButton(
                  text: 'Holiwi',
                  width: 340.0,
                  isDisabled: !currentPlayersProvider.didAllPlayersVote,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerBetContainer extends StatelessWidget {
  final int playerIndex;

  const PlayerBetContainer({
    super.key,
    required this.playerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          height: 120.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentPlayersProvider.currentPlayers[playerIndex].name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '+5',
                      style: TextStyle(
                        color: CustomColors.correctColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      '${currentPlayersProvider.currentPlayers[playerIndex].score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        height: 50.0,
                        width: 100.0,
                        child: HorizontalNumberSelector(
                            currentPlayer: currentPlayersProvider
                                .currentPlayers[playerIndex].name)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<String> numberList = ['-', '0', '1', '2', '3', '4', '5', '6'];

class HorizontalNumberSelector extends StatefulWidget {
  final String currentPlayer;
  const HorizontalNumberSelector({super.key, required this.currentPlayer});

  @override
  State<HorizontalNumberSelector> createState() =>
      _HorizontalNumberSelectorState();
}

class _HorizontalNumberSelectorState extends State<HorizontalNumberSelector> {
  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return ScrollSnapList(
      itemBuilder: _buildItemList,
      itemCount: numberList.length,
      background: Colors.amber,
      itemSize: 40.0,
      margin: const EdgeInsets.symmetric(horizontal: 0.5),
      dynamicItemSize: true,
      onItemFocus: (index) {
        // find the matching player and modify vote according
        // to the selected numberList
        currentPlayersProvider.currentPlayers
            .firstWhere(
              (player) => player.name == widget.currentPlayer,
            )
            .vote = numberList[index];
            
        // check if everybody voted
        currentPlayersProvider.checkIfAllPlayersVoted();
      },
      dynamicItemOpacity: 0.4,
    );
  }
}

Widget _buildItemList(BuildContext context, int index) {
  return SizedBox(
    width: 40.0,
    child: Center(
      child: Text(
        numberList[index],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
