import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/firestore.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

List<PlayerInRank> allPlayersList = [];

class _RankingPageState extends State<RankingPage> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  // dropdown controller
  final TextEditingController sortController = TextEditingController();

  // selected sorting dropdown
  SortLabelDropdown? selectedSort;

  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();

    // we set the list with all players with checks
    currentPlayersProvider.setAllPlayersList();

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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // if we open the dropdown we clear the bottom round corners
                          borderRadius: currentPlayersProvider.openRankDropdown
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(8.0),
                                )
                              : BorderRadius.circular(8.0),
                        ),
                        child: CustDropDown(
                          items: currentPlayersProvider.dropdownValues
                              .map<CustDropdownMenuItem<SortLabelDropdown>>(
                                  (SortLabelDropdown sort) {
                            return CustDropdownMenuItem<SortLabelDropdown>(
                              value: sort,
                              child: Text(
                                sort.label,
                                style: const TextStyle(
                                  backgroundColor: CustomColors.whiteColor,
                                  color: CustomColors.bgGradient1,
                                  fontSize: 22.0,
                                ),
                              ),
                            );
                          }).toList(),
                          maxListHeight: 600.0,
                          defaultSelectedIndex: 0,
                          borderRadius: 8.0,
                          onChanged: (SortLabelDropdown? sort) {
                            selectedSort = sort;
                            currentPlayersProvider.setSortingRank(sort!.value);
                            currentPlayersProvider.setDropdownValues(sort.value);
                          },
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
                              currentPlayersProvider.sortingRank,
                              currentPlayersProvider.allPlayersList),
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
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) =>
                                  const SelectPlayersDialogbox(),
                            ).then((_) {
                              // Trigger a rebuild of the ranking_page here
                              setState(() {});
                            });
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
                      stream: firestoreService.getPlayersSorted(
                          currentPlayersProvider.sortingRank,
                          currentPlayersProvider.allPlayersList),
                      builder: (context, snapshot) {
                        // if we are waiting for data, show loading progress
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingProgress();
                        }
                        // if we have data, get all docs
                        if (snapshot.hasData) {
                          List playersList = snapshot.data!.docs;

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
