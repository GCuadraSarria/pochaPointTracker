// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_slot_machine/slot_machine.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:provider/provider.dart';

class DealerPlayersPage extends StatefulWidget {
  const DealerPlayersPage({super.key});

  @override
  State<DealerPlayersPage> createState() => _DealerPlayersPageState();
}

class _DealerPlayersPageState extends State<DealerPlayersPage> {
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
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return Consumer<CurrentPlayers>(
      builder: (context, value, child) => SafeArea(
        child: Scaffold(
          // avoids keyboard pushing bottom content
          body: Padding(
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
                              Image.asset('lib/assets/icons/step_icon_3.png'),
                        ),
                      ),
                      const Text(
                        '¿Quién reparte?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // players list animation
                MySlotMachine(items: currentPlayersProvider.currentPlayers),
                const SizedBox(height: 100),
                Text(
                  'Haz tap para parar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(),

                // back and next buttons
                const GoBackButton(),
                CustomButton(
                  text: 'Empezar partida',
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
