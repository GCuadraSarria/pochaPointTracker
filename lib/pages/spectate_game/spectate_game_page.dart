import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../../services/firestore.dart';

class SpectateGamePage extends StatefulWidget {
  const SpectateGamePage({super.key});

  @override
  State<SpectateGamePage> createState() => _SpectateGamePageState();
}

class _SpectateGamePageState extends State<SpectateGamePage> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
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
                          'Partidas en curso',
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

                  // games displayed
                  Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firestoreService.getCurrentGamesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingProgress();
                        }
                        if (snapshot.hasData) {
                          List gameList = snapshot.data!.docs;
                          if (gameList.isEmpty) {
                            return const Center(
                              child: Text(
                                'No hay partidas en curso',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: CustomColors.whiteColor,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              itemCount: gameList.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot document = gameList[index];

                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                List<String> players =
                                    List<String>.from(data['players'] ?? []);
                                // Formatear la fecha
                                String formattedDate = '';
                                if (data['startDate'] is Timestamp) {
                                  DateTime dateTime =
                                      (data['startDate'] as Timestamp).toDate();
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
                                                SpectateGameDetailPage(
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
                                                    color:
                                                        CustomColors.whiteColor,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w400,
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
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Expanded(
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
                                );
                              },
                            );
                          }
                        } else {
                          return const SizedBox.shrink();
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
