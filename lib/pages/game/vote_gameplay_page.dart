import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:provider/provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:wakelock/wakelock.dart';

class VoteGameplayPage extends StatefulWidget {
  const VoteGameplayPage({super.key});

  @override
  State<VoteGameplayPage> createState() => _VoteGameplayPageState();
}

class _VoteGameplayPageState extends State<VoteGameplayPage> {
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
    // provider
    final currentPlayersProvider = context.read<CurrentPlayers>();

    // avoid blackscreen
    Wakelock.enable();

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
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ronda ${currentPlayersProvider.round}${currentPlayersProvider.lastRound && currentPlayersProvider.wePlayIndia ? ' (Ciega)' : ''}',
                          style: const TextStyle(
                            color: CustomColors.whiteColor,
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
                        Text(
                          '${currentPlayersProvider.numberOfCards} carta${currentPlayersProvider.numberOfCards == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: CustomColors.whiteColor,
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
                            color: CustomColors.whiteColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          currentPlayersProvider.currentPlayers.last.playerName,
                          style: const TextStyle(
                            color: CustomColors.whiteColor,
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
                            color: CustomColors.whiteColor,
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
                          return PlayerVoteContainer(playerIndex: index);
                        }),
                  ),
                  // next button
                  CustomButton(
                    text: 'Bazas',
                    width: 340.0,
                    isDisabled: !currentPlayersProvider.didAllPlayersVote,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BazGameplayPage()),
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

class PlayerVoteContainer extends StatelessWidget {
  final int playerIndex;

  const PlayerVoteContainer({
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
          height: 110.0,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CustomColors.whiteColor, width: 1.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentPlayersProvider
                          .currentPlayers[playerIndex].playerName,
                      style: const TextStyle(
                        color: CustomColors.whiteColor,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 10.0),
                    Text(
                      '${currentPlayersProvider.currentPlayers[playerIndex].score}',
                      style: const TextStyle(
                        color: CustomColors.whiteColor,
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
                    // right horizontal scroll
                    SizedBox(
                        height: 50.0,
                        width: 100.0,
                        child: HorizontalNumberSelectorVote(
                            currentPlayer: currentPlayersProvider
                                .currentPlayers[playerIndex].playerName)),
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

// horizontal scroll class
class HorizontalNumberSelectorVote extends StatefulWidget {
  final String currentPlayer;
  const HorizontalNumberSelectorVote({super.key, required this.currentPlayer});

  @override
  State<HorizontalNumberSelectorVote> createState() =>
      _HorizontalNumberSelectorVoteState();
}

class _HorizontalNumberSelectorVoteState
    extends State<HorizontalNumberSelectorVote> {
  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color.fromRGBO(255, 255, 255, 0.0),
          Color.fromRGBO(255, 255, 255, 0.2),
          Color.fromRGBO(255, 255, 255, 1.0),
          Color.fromRGBO(255, 255, 255, 0.2),
          Color.fromRGBO(255, 255, 255, 0.0),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: ScrollSnapList(
        itemBuilder: _buildItemList,
        itemCount: currentPlayersProvider.scrollableNumberList.length,
        itemSize: 40.0,
        margin: const EdgeInsets.symmetric(horizontal: 0.5),
        dynamicItemSize: true,
        onItemFocus: (index) {
          // find the matching player and modify vote according
          // to the selected numberList
          currentPlayersProvider.currentPlayers
              .firstWhere(
                (player) => player.playerName == widget.currentPlayer,
              )
              .vote = currentPlayersProvider.scrollableNumberList[index];

          // check if everybody voted
          currentPlayersProvider.checkIfAllPlayersVoted();

          // modify points based on the selection
          currentPlayersProvider.checkPlayerPoints(widget.currentPlayer);
        },
        dynamicItemOpacity: 0.4,
      ),
    );
  }
}

Widget _buildItemList(BuildContext context, int index) {
  final currentPlayersProvider = context.read<CurrentPlayers>();
  return SizedBox(
    width: 40.0,
    child: Center(
      child: Text(
        currentPlayersProvider.scrollableNumberList[index],
        style: const TextStyle(
          color: CustomColors.whiteColor,
          fontSize: 40.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
