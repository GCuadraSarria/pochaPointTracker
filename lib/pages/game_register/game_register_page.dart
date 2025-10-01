import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocha_points_tracker/pages/game_register_detail/game_register_total_detail_page.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/select_players_game_register_dialogbox.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../../services/firestore.dart';

class GameRegisterPage extends StatefulWidget {
  const GameRegisterPage({super.key});

  @override
  State<GameRegisterPage> createState() => _GameRegisterPageState();
}

class _GameRegisterPageState extends State<GameRegisterPage> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();
  @override
  void initState() {
    super.initState();
    // Llama solo una vez al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrentPlayers>().setAllPlayersList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlayerNames = context
        .watch<CurrentPlayers>()
        .allPlayersList
        .where((player) => player.selected)
        .map((player) => player.playerName)
        .toList();

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
                          'Registro de partidas',
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
                  // filtros
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => context
                            .read<CurrentPlayers>()
                            .clearSelectedPlayers(),
                        child: const Text(
                          'Limpiar filtros',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: CustomColors.whiteColor,
                            color: CustomColors.whiteColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await context
                              .read<CurrentPlayers>()
                              .setAllPlayersList();
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) =>
                                const SelectPlayersGameRegisterDialogbox(),
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
                  const SizedBox(height: 16.0),
                  // games displayed
                  Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: firestoreService
                            .getGamesByExactPlayers(selectedPlayerNames),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LoadingProgress();
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(
                              child: Text(
                                'No hay registro de partidas',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: CustomColors.whiteColor,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }
                          final filteredDocs = selectedPlayerNames.isEmpty
                              ? snapshot.data!.docs
                              : snapshot.data!.docs.where((doc) {
                                  final players =
                                      List<String>.from(doc['players'] ?? []);
                                  final normalizedPlayers = players
                                      .map((e) => e.trim().toLowerCase())
                                      .toSet();
                                  final normalizedSelected = selectedPlayerNames
                                      .map((e) => e.trim().toLowerCase())
                                      .toSet();
                                  return normalizedPlayers.length ==
                                          normalizedSelected.length &&
                                      normalizedPlayers
                                          .containsAll(normalizedSelected);
                                }).toList();

                          if (filteredDocs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No hay registro de partidas',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: CustomColors.whiteColor,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                        color: CustomColors.whiteColor,
                                        width: 1.5),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              GameRegisterTotalDetailPage(
                                                  players: selectedPlayerNames),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 8,
                                            children: [
                                              Text(
                                                'Total',
                                                style: TextStyle(
                                                  color:
                                                      CustomColors.whiteColor,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.arrow_forward_ios),
                                            ],
                                          ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filteredDocs.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot document =
                                        filteredDocs[index];

                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;
                                    List<String> players = List<String>.from(
                                        data['players'] ?? []);
                                    // Formatear la fecha
                                    String formattedDate = '';
                                    if (data['startDate'] is Timestamp) {
                                      DateTime dateTime =
                                          (data['startDate'] as Timestamp)
                                              .toDate();
                                      formattedDate =
                                          DateFormat('dd/MM/yyyy - HH:mm')
                                              .format(dateTime);
                                    } else if (data['startDate'] is String) {
                                      formattedDate = data['startDate'];
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                              color: CustomColors.whiteColor,
                                              width: 1.5),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    GameRegisterDetailPage(
                                                        gameId: document.id),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  spacing: 8,
                                                  children: [
                                                    Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                        color: CustomColors
                                                            .whiteColor,
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    Text(
                                                      players.join(', '),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: CustomColors
                                                            .bgGradient4,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Expanded(
                                                    child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Icon(Icons
                                                        .arrow_forward_ios),
                                                  ],
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
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
