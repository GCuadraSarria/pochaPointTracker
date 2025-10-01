import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/achievement/all_achievements_list_view.dart';
import 'package:pocha_points_tracker/pages/achievement/player_achievements_view.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:provider/provider.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Row(
                        children: [
                          Text(
                            'Logros',
                            style: TextStyle(
                              color: CustomColors.whiteColor,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Tabs aquí
                    TabBar(
                      labelColor: CustomColors.whiteColor,
                      unselectedLabelColor: Colors.white54,
                      indicatorColor: CustomColors.primaryColor,
                      indicatorWeight: 3.0,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: EdgeInsets.symmetric(horizontal: 12),
                      tabs: [
                        Tab(text: 'Todos'),
                        Tab(text: 'Por jugador'),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TabBarView(
                          children: [
                            AllAchievementsListView(), // tu widget para todos los logros
                            PlayerAchievementsView(), // tu widget para logros por jugador
                          ],
                        ),
                      ),
                    ),
                    // back and next buttons
                    GoBackButton(btnText: 'Atrás'),
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
