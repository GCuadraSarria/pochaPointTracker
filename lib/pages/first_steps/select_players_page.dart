import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:provider/provider.dart';

class SelectPlayersPage extends StatefulWidget {
  const SelectPlayersPage({super.key});

  @override
  State<SelectPlayersPage> createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  // sort by games / name
  late bool sortByGames = true;

  // bool to disable button
  late bool isButtonDisabled = true;

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
          // avoids keyboard pushing bottom content
          resizeToAvoidBottomInset: false,
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
                                Image.asset('lib/assets/icons/step_icon_1.png'),
                          ),
                        ),
                        const Text(
                          '¿Quién juega?',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        child: Text(
                          'Jugadores:',
                          style: TextStyle(
                            color: CustomColors.whiteColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            sortByGames ? 'por partidas' : 'por nombre',
                            style: const TextStyle(
                              color: CustomColors.whiteColor,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                sortByGames = !sortByGames;
                              });
                            },
                            icon: const Icon(Icons.filter_list),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // players list
                  Flexible(
                    flex: 3,
                    child: StreamBuilder<QuerySnapshot>(
                      // get players sorted by name or points
                      stream: sortByGames
                          ? firestoreService.showPlayersInfoSorted('gamesPlayed')
                          : firestoreService.showPlayersInfoSorted('playerName'),
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
                                bool playerDoPlay = data['doIplay'];
            
                                // display as a list tile
                                return PlayerSelection(
                                    playerName: playerName,
                                    playerDoPlay: playerDoPlay);
                              });
                          // if there is no data return nothing
                        } else {
                          return const LoadingProgress();
                        }
                      },
                    ),
                  ),
            
                  const SizedBox(height: 24.0),
            
                  // new player button
                  GestureDetector(
                    onTap: () => newPlayerAlertbox(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) => const LinearGradient(
                            colors: [
                              CustomColors.primaryColor,
                              CustomColors.secondaryColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.add_circle_outline,
                            size: 32.0,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        const Text(
                          'Nuevo jugador',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: CustomColors.whiteColor,
                            color: CustomColors.whiteColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
            
                  // back and next buttons
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    ),
                    child: const Text(
                      'Atrás',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: CustomColors.whiteColor,
                        color: CustomColors.whiteColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CustomButton(
                    text: 'Ir a ordenar jugadores',
                    width: 340.0,
                    // disable button if less than two players are selected
                    isDisabled: currentPlayersProvider.isButtonDisabled,
                    onPressed: () {
                      // we clear the player list before adding the players
                      currentPlayersProvider.currentPlayers.clear();
                      currentPlayersProvider.addPlayers();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SortPlayersPage()),
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
