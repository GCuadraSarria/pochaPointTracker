import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../../services/firestore.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

// dropdownMenuEntry labels and values for the dropdown menu.
enum SortLabel {
  gamesPlayed('Partidas jugadas', 'gamesPlayed'),
  winGames('Partidas ganadas', 'winGames'),
  gamesWinRate('Porcentaje de victorias', 'gamesWinRate'),
  maxPoints('Puntuación máxima', 'maxPoints');

  const SortLabel(this.label, this.value);
  final String label;
  final String value;
}

class _RankingPageState extends State<RankingPage> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  // dropdown controller
  final TextEditingController sortController = TextEditingController();

  // selected sorting dropdown
  SortLabel? selectedSort;

  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();

    // local number of players
    Future<int> filteredPlayers = firestoreService.getPlayerCount();

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
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estadísticas',
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        Text(
                          'Ver estadísticas por',
                          style: TextStyle(
                            color: CustomColors.whiteColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // select sorting value dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        height: 60.0,
                        color: CustomColors.whiteColor,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            padding: const EdgeInsets.all(12.0),
                            hint: Text(
                              SortLabel.gamesPlayed.label,
                              style: const TextStyle(
                                color: CustomColors.backgroundColor,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.expand_more,
                              color: CustomColors.backgroundColor,
                            ),
                            style: const TextStyle(
                                backgroundColor: CustomColors.whiteColor,
                                color: CustomColors.backgroundColor,
                                fontSize: 22.0),
                            dropdownColor: CustomColors.whiteColor,
                            borderRadius: BorderRadius.circular(8.0),
                            value: selectedSort,
                            onChanged: (SortLabel? sort) {
                              selectedSort = sort;
                              currentPlayersProvider
                                  .setSortingRank(sort!.value);
                            },
                            items: SortLabel.values
                                .map<DropdownMenuItem<SortLabel>>(
                                    (SortLabel sort) {
                              return DropdownMenuItem<SortLabel>(
                                value: sort,
                                child: Text(sort.label),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          // get players and their stats
                          stream: firestoreService.getPlayersSorted(
                              currentPlayersProvider.sortingRank),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const LoadingProgress();
                            }
                            // if we have data, get all docs
                            if (snapshot.hasData) {
                              List playersList = snapshot.data!.docs;

                              // display as a list
                              return Text(
                                ('Jugadores (${playersList.length})'),
                                style: const TextStyle(
                                  color: CustomColors.whiteColor,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                              // if there is no data return nothing
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            // select player dialog
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                                  const SelectPlayersDialogbox(),
                            );
                          },
                          child: const Text(
                            'Seleccionar',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: CustomColors.whiteColor,
                              color: CustomColors.whiteColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // players displayed
                  Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      // get players and their stats
                      stream: firestoreService
                          .getPlayersSorted(currentPlayersProvider.sortingRank),
                      builder: (context, snapshot) {
                        // if we are waiting for data, show loading progress
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingProgress();
                        }
                        // if we have data, get all docs
                        if (snapshot.hasData) {
                          List playersList = snapshot.data!.docs;
                          // set number of players in the list
                          currentPlayersProvider
                              .filteredPlayers(playersList.length);

                          // display as a list
                          return ListView.builder(
                              itemCount: playersList.length,
                              itemBuilder: (context, index) {
                                // get each individual doc
                                DocumentSnapshot document = playersList[index];

                                // get player from each doc
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                String playerName = data['playerName'];
                                String sortingInfo =
                                    currentPlayersProvider.sortingRank;

                                // display as a list tile
                                return PlayerRankingTile(
                                  index: index,
                                  playerName: playerName,
                                  sortingInformation: data[sortingInfo],
                                );
                              });
                          // if there is no data return nothing
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),

                  // back and next buttons
                  const GoBackButton(),
                  CustomButton(
                    text: 'Nueva partida',
                    width: 340.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SelectPlayersPage()),
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
