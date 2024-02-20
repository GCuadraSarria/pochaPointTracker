import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_text_reveal/random_text_reveal.dart';
import 'package:pocha_points_tracker/pages/game/vote_gameplay_page.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';

class DealerPlayersPage extends StatefulWidget {
  const DealerPlayersPage({super.key});

  @override
  State<DealerPlayersPage> createState() => _DealerPlayersPageState();
}

class _DealerPlayersPageState extends State<DealerPlayersPage> {
  // firestore service
  final FirestoreService firestoreService = FirestoreService();

// finished tap flag
  bool ableButton = false;

// method to set the flag
  void enableStartButton() {
    setState(() {
      ableButton = true;
    });
    debugPrint('able button: $ableButton');
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();

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
                          '¿Quién va a repartir?',
                          style: TextStyle(
                            color: CustomColors.whiteColor,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // players list animation
                  const RandomTextDecode(),
                  const Spacer(),
            
                  // back and next buttons
                  const GoBackButton(),
                  CustomButton(
                    text: 'Empezar partida',
                    width: 340.0,
                    isDisabled: !currentPlayersProvider.dealerFlag,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VoteGameplayPage()),
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

class RandomTextDecode extends StatelessWidget {
  const RandomTextDecode({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // provider
    final currentPlayersProvider = context.read<CurrentPlayers>();

    // dealer
    late String dealer;

    // method that randomize a player to be the dealer
    void randomPlayer() {
      // generate random number to get index
      final random = Random();
      int randomIndex =
          random.nextInt(currentPlayersProvider.currentPlayers.length - 1);
      // return name based on the index
      dealer = currentPlayersProvider.currentPlayers[randomIndex].playerName;
    }

    // we call the method
    randomPlayer();

    return Expanded(
      child: RandomTextReveal(
        initialText: 'Ae8&vNQ32cK^',
        shouldPlayOnStart: true,
        text: dealer,
        duration: const Duration(seconds: 3),
        style: const TextStyle(
          fontSize: 38.0,
          color: CustomColors.whiteColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        randomString: Source.alphabets,
        onFinished: () {
          // Delay the execution of gotDealer() to ensure it's not called during build
          Future.delayed(Duration.zero, () {
            currentPlayersProvider.gotDealer();
            currentPlayersProvider.sortByMatch(dealer);
          });
        },
        curve: Curves.easeIn,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
