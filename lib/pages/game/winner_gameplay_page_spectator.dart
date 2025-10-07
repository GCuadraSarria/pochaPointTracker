import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WinnerGameplayPageSpectator extends StatefulWidget {
  final String gameId;
  const WinnerGameplayPageSpectator({required this.gameId, super.key});

  @override
  State<WinnerGameplayPageSpectator> createState() =>
      _WinnerGameplayPageSpectatorState();
}

class _WinnerGameplayPageSpectatorState
    extends State<WinnerGameplayPageSpectator> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('games')
            .doc(widget.gameId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final gameData = snapshot.data!.data() as Map<String, dynamic>;
          final Map<String, dynamic> scoresMap =
              Map<String, dynamic>.from(gameData['scores'] ?? {});

          // Ordenamos los jugadores por score descendente
          final sortedPlayers = scoresMap.entries.toList()
            ..sort((a, b) => (b.value as int).compareTo(a.value as int));

          // Detectamos la puntuación máxima
          final int maxScore =
              sortedPlayers.isNotEmpty ? sortedPlayers.first.value as int : 0;
          // Todos los jugadores que tienen la puntuación máxima
          final winnerList = sortedPlayers
              .where((entry) => entry.value == maxScore)
              .map((e) => e.key)
              .toList();

          // Widgets para UI
          List<Widget> buildWinnerWidgets() {
            return winnerList.map((winner) {
              return Text(
                '$winner wins',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomColors.whiteColor,
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: CustomColors.backgroundColor,
                      blurRadius: 3.0,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              );
            }).toList();
          }

          return StreamBuilder<Object>(
              stream: null,
              builder: (context, snapshot) {
                return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('achievements')
                        .snapshots(),
                    builder: (context, snapshotAchievements) {
                      final Set<String> shownAchievements = {};

                      if (snapshotAchievements.hasData) {
                        for (final doc in snapshotAchievements.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final players = List<Map<String, dynamic>>.from(
                              data['players'] ?? []);
                          final completed = players
                              .where((p) => p['completado'] == true)
                              .toList();

                          if (completed.isNotEmpty) {
                            final last = completed.last;
                            final achievementKey = '${doc.id}_${last['name']}';

                            // Solo muestra si no está en achievements completados ni en los ya mostrados en esta sesión
                            final completedAchievements = context
                                .read<CurrentPlayers>()
                                .completedAchievements;
                            if (!completedAchievements
                                    .contains(achievementKey) &&
                                !shownAchievements.contains(achievementKey)) {
                              shownAchievements.add(achievementKey);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context
                                    .read<CurrentPlayers>()
                                    .showExternalAchievement(
                                      docId: doc.id,
                                      playerName: last['name'],
                                      achievementName: data['name'],
                                      achievementDescription:
                                          data['description'],
                                    );
                              });
                            }
                          }
                        }
                      }
                      return Consumer<CurrentPlayers>(
                        builder: (context, value, child) => SafeArea(
                          child: Scaffold(
                            body: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GameRegisterDetailPage(
                                            gameId: widget.gameId,
                                          )),
                                );
                              },
                              child: Container(
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // show winner
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                      'lib/assets/images/winning_cup.svg',
                                                      semanticsLabel:
                                                          'winning cup'),
                                                  const SizedBox(height: 15),
                                                  // we get all the currentplayers.winner = true
                                                  Column(
                                                      children:
                                                          buildWinnerWidgets()),
                                                  const SizedBox(height: 15),
                                                  Text(
                                                    '$maxScore puntos',
                                                    style: const TextStyle(
                                                      color: CustomColors
                                                          .whiteColor,
                                                      fontSize: 24.0,
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      shadows: [
                                                        Shadow(
                                                          color: CustomColors
                                                              .backgroundColor,
                                                          blurRadius: 3.0,
                                                          offset:
                                                              Offset(5.0, 5.0),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              });
        });
  }
}
