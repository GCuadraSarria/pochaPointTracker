import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

import '../models/player_model.dart';
import '../provider/provider.dart';
import 'widgets.dart';

class SelectPlayersDialogbox extends StatefulWidget {
  const SelectPlayersDialogbox({super.key});

  @override
  State<SelectPlayersDialogbox> createState() => _SelectPlayersDialogboxState();
}

class _SelectPlayersDialogboxState extends State<SelectPlayersDialogbox> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  // Define a variable to hold the initial state
  List<PlayerInRank> initialList = [];

  @override
  void initState() {
    // Fetch the initial state of allPlayersList
    initialList = context.read<CurrentPlayers>().allPlayersList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();

    // Create a deep copy of the list
    final List<PlayerInRank> localList = List<PlayerInRank>.from(
      initialList.map((player) => PlayerInRank(
            playerName: player.playerName,
            selected: player.selected,
          )),
    );

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
            child: Dialog.fullscreen(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            // if we close the modal we apply the last state to the list
                            currentPlayersProvider.applyLocalList(localList);
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: CustomColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          'Seleccionar jugadores',
                          style: TextStyle(
                            color: CustomColors.whiteColor,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // select / unselect all button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // update the users based on the selection
                              currentPlayersProvider.swapSelectAll();
                              // check the state of the button to disalbe it
                              currentPlayersProvider.setNotPlayersSelected();
                            });
                          },
                          child: Text(
                            currentPlayersProvider.selectedAllSort
                                ? 'Deseleccionar todo'
                                : 'Seleccionar todo',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: CustomColors.whiteColor,
                              color: CustomColors.whiteColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // players list
                    Flexible(
                      child: ListView.builder(
                          itemCount:
                              currentPlayersProvider.allPlayersList.length,
                          itemBuilder: (context, index) {
                            // display as a list tile
                            return PlayerRankingSelection(
                              playerName: currentPlayersProvider
                                  .allPlayersList[index].playerName,
                              selected: currentPlayersProvider
                                  .allPlayersList[index].selected,
                              index: index,
                            );
                          }),
                    ),
                    // compare button
                    CustomButton(
                      text: 'Comparar jugadores',
                      isDisabled: currentPlayersProvider.notPlayersSelected,
                      width: 340.0,
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
