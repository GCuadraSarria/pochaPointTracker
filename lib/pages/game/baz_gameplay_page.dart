import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';

class BazGameplayPage extends StatefulWidget {
  const BazGameplayPage({super.key});

  @override
  State<BazGameplayPage> createState() => _BazGameplayPageState();
}

class _BazGameplayPageState extends State<BazGameplayPage> {
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
    // provider service
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
                          'Bazas ganadas',
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
                          return PlayerBazContainer(playerIndex: index);
                        }),
                  ),
                  // back and next buttons
                  const GoBackButton(),
                  CustomButton(
                    text: currentPlayersProvider.lastRound
                        ? 'Finalizar partida'
                        : 'Siguente ronda',
                    width: 340.0,
                    isDisabled: !currentPlayersProvider.didAllPlayersBaz,
                    onPressed: !currentPlayersProvider.lastRound
                        ? () {
                            //not last round,
                            currentPlayersProvider.nextRound();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VoteGameplayPage(),
                              ),
                            );
                          }
                        : () {
                            //last round,
                            currentPlayersProvider.finishGame();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WinnerGameplayPage(),
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

class PlayerBazContainer extends StatelessWidget {
  final int playerIndex;

  const PlayerBazContainer({
    super.key,
    required this.playerIndex,
  });

  @override
  Widget build(BuildContext context) {
    // provider
    final currentPlayersProvider = context.read<CurrentPlayers>();

    //widget that controlls the text displayed based on the local points
    Widget obtainedPointsText() {
      if (currentPlayersProvider.currentPlayers[playerIndex].localPoints == 0) {
        return const Text('');
      } else if (currentPlayersProvider
              .currentPlayers[playerIndex].localPoints >
          0) {
        return Text(
          '+${currentPlayersProvider.currentPlayers[playerIndex].localPoints}',
          style: const TextStyle(
            color: CustomColors.correctColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
        );
      } else {
        return Text(
          '${currentPlayersProvider.currentPlayers[playerIndex].localPoints}',
          style: const TextStyle(
            color: CustomColors.errorColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
        );
      }
    }

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
                    // local points widget call
                    obtainedPointsText(),
                    // player score
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
                    // left vote number display
                    SizedBox(
                      height: 50.0,
                      width: 100.0,
                      child: SizedBox(
                        width: 40.0,
                        child: Center(
                          child: Text(
                            currentPlayersProvider
                                .currentPlayers[playerIndex].vote,
                            style: const TextStyle(
                              color: CustomColors.whiteColor,
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // right horizontal scroll
                    SizedBox(
                        height: 50.0,
                        width: 100.0,
                        child: HorizontalNumberSelectorBaz(
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
class HorizontalNumberSelectorBaz extends StatefulWidget {
  final String currentPlayer;
  const HorizontalNumberSelectorBaz({super.key, required this.currentPlayer});

  @override
  State<HorizontalNumberSelectorBaz> createState() =>
      _HorizontalNumberSelectorBazState();
}

class _HorizontalNumberSelectorBazState
    extends State<HorizontalNumberSelectorBaz> {
  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return ShaderMask(
      shaderCallback: (bounds) =>
          CustomColors.shadowGradient.createShader(bounds),
      child: ScrollSnapList(
        itemBuilder: _buildItemList,
        itemCount: currentPlayersProvider.scrollableNumberList.length,
        itemSize: 40.0,
        onItemFocus: (index) {
          // find the matching player and modify baz according
          // to the selected numberList
          currentPlayersProvider.currentPlayers
              .firstWhere(
                (player) => player.playerName == widget.currentPlayer,
              )
              .baz = currentPlayersProvider.scrollableNumberList[index];

          // check if everybody baz
          currentPlayersProvider.checkIfAllPlayersBaz();

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
