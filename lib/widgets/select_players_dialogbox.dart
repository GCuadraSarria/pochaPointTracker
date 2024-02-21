import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

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

  // all selected initially
  bool allSelected = true;

  // get a list of the players
  List<List<dynamic>> rankPlayers = [];

  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();

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
              backgroundColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'X',
                            style: TextStyle(
                              color: CustomColors.whiteColor,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w400,
                            ),
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
                              allSelected = !allSelected;                              
                              firestoreService.selectAll(allSelected);
                            });
                          },
                          child: Text(
                            allSelected
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
                      child: StreamBuilder<QuerySnapshot>(
                        // get players sorted by name or points
                        stream: firestoreService
                            .showPlayersInfoSorted('playerName'),
                        builder: (context, snapshot) {
                          // if we have data, get all docs
                          if (snapshot.hasData) {
                            List playersList = snapshot.data!.docs;

                            // display as a list
                            return ListView.builder(
                                itemCount: playersList.length,
                                itemBuilder: (context, index) {
                                  // get each individual doc
                                  DocumentSnapshot document =
                                      playersList[index];

                                  // get player from each doc
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  String playerName = data['playerName'];
                                  bool selectionRank = data['selectionRank'];

                                  // display as a list tile
                                  return PlayerRankingSelection(
                                    playerName: playerName,
                                    selectionRank: selectionRank,
                                  );
                                });
                            // if there is no data return nothing
                          } else {
                            return const LoadingProgress();
                          }
                        },
                      ),
                    ),
                    // compare button
                    CustomButton(
                      text: 'Comparar jugadores',
                      width: 340.0,
                      onPressed: () {
                        //TODO: Apply changes
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
