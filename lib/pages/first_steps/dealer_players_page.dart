import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/game/vote_gameplay_page.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
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

  // finished tap flag
  bool ableButton = false;

  // method to set the flag
  bool enableStartButton() {
    ableButton = true;
    return ableButton;
  }

  @override
  Widget build(BuildContext context) {
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
                MySlotMachine(
                    enableStartButton: enableStartButton,
                    items: currentPlayersProvider.currentPlayers
                        .map((player) => player.name)
                        .toList()),
                const SizedBox(height: 100),
                const Text(
                  'Haz tap para parar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(),

                // back and next buttons
                GoBackButton(),
                CustomButton(
                  text: 'Empezar partida',
                  width: 340.0,
                  isDisabled: !ableButton,
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
    );
  }
}

class MySlotMachine extends StatefulWidget {
  final List<String> items;
  final Function enableStartButton;

  const MySlotMachine(
      {super.key, required this.items, required this.enableStartButton});

  @override
  MySlotMachineState createState() => MySlotMachineState();
}

class MySlotMachineState extends State<MySlotMachine> {
  late FixedExtentScrollController scrollController;
  late Timer? timer;
  int selectedItem = 0;
  // flag to avoid more taps
  bool stopTap = false;

  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController(initialItem: selectedItem);
    startSpinning();
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer if it's not null
    super.dispose();
  }

  void startSpinning() {
    const duration = Duration(milliseconds: 100);
    timer = Timer.periodic(duration, (Timer timer) {
      setState(() {
        selectedItem++;
        if (selectedItem == widget.items.length) {
          selectedItem = 0;
        }
        scrollController.animateToItem(
          selectedItem,
          duration: duration,
          curve: Curves.linear,
        );
      });
    });
  }

  void stopSpinning() {
    timer?.cancel();
    stopTap = true;

    // Calculate the final selected item based on the current scroll offset
    final currentOffset = scrollController.position.pixels;
    const itemExtent = 55.0; // Update with your item extent
    final itemCount = widget.items.length * 100;
    final targetItem = (currentOffset / itemExtent).round() % itemCount;

    // Update the selected item and sort by match
    setState(() {
      widget.enableStartButton();
      selectedItem = targetItem;
      context.read<CurrentPlayers>().sortByMatch(selectedItem);
    });
    print('Dealer -> ${widget.items[selectedItem]}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !stopTap ? stopSpinning : null,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SizedBox(
            height: 150,
            child: ListWheelScrollView.useDelegate(
              controller: scrollController,
              physics: const FixedExtentScrollPhysics(),
              itemExtent: 55,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final itemIndex = index % widget.items.length;
                  return Text(
                    widget.items[itemIndex],
                    style: const TextStyle(
                      fontSize: 38.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
                childCount: widget.items.length *
                    1000, // Large number for looping effect
              ),
            ),
          ),
          Container(
            height: 150,
            width: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(29, 29, 29, 1.0), // 100% opacity
                    Color.fromRGBO(29, 29, 29, 0.0), // 0% opacity
                    Color.fromRGBO(29, 29, 29, 1.0), // 100% opacity
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
