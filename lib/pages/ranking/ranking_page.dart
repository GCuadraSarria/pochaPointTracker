import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

class _RankingPageState extends State<RankingPage> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => SafeArea(
        child: Scaffold(
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      Text(
                        'Ranking',
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
                const InformationRow(),
                Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                    // get players and their stats
                    stream: firestoreService.showPlayersInfoSorted(currentPlayersProvider.sortingRank),
                    builder: (context, snapshot) {
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
                              int gamesPlayed = data['gamesPlayed'];
                              int winGames = data['winGames'];
                              double gamesWinRate = data['gamesWinRate'];

                              // display as a list tile
                              return PlayerRankingTile(
                                playerName: playerName,
                                gamesPlayed: gamesPlayed,
                                winGames: winGames,
                                gamesWinRate: gamesWinRate,
                              );
                            });
                        // if there is no data return nothing
                      } else {
                        return const LoadingProgress();
                      }
                    },
                  ),
                ),
                const Spacer(),

                // back and next buttons
                const GoBackButton(),
                CustomButton(
                  text: 'xd',
                  width: 340.0,
                  isDisabled: true,
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

// information of the ranking stats table with dynamic text buttons
class InformationRow extends StatelessWidget {
  const InformationRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CustomColors.whiteColor, width: 1.0),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: SortingBtnText(
                btnText: 'Nombre',
                sortValue: 'playerName',
              ),
            ),
            Expanded(
              child: SortingBtnText(
                btnText: 'P',
                sortValue: 'gamesPlayed',
              ),
            ),
            Expanded(
              child: SortingBtnText(
                btnText: 'G',
                sortValue: 'winGames',
              ),
            ),
            Expanded(
              child: SortingBtnText(
                btnText: 'W%',
                sortValue: 'gamesWinRate',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// button in the top of the columns to sort the tiles

class SortingBtnText extends StatelessWidget {
  final String btnText;
  final String sortValue;
  const SortingBtnText({
    super.key,
    required this.btnText,
    required this.sortValue,
  });

  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return TextButton(
      onPressed: () => currentPlayersProvider.setSortingRank(sortValue),
      child: Text(
        btnText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
