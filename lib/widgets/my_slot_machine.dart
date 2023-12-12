import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:provider/provider.dart';

class MySlotMachine extends StatefulWidget {
  final List<String> items;

  const MySlotMachine({super.key, required this.items});

  @override
  MySlotMachineState createState() => MySlotMachineState();
}

class MySlotMachineState extends State<MySlotMachine> {
  late FixedExtentScrollController scrollController;
  late Timer? timer;
  int selectedItem = 0;

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

    // Calculate the final selected item based on the current scroll offset
    final currentOffset = scrollController.position.pixels;
    const itemExtent = 55.0; // Update with your item extent
    final itemCount = widget.items.length * 100;
    final targetItem = (currentOffset / itemExtent).round() % itemCount;

    // Update the selected item and sort by match
    setState(() {
      selectedItem = targetItem;
      context.read<CurrentPlayers>().sortByMatch(widget.items[selectedItem]);
    });
    print('Dealer -> ${widget.items[selectedItem]}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: stopSpinning,
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
                    100, // Large number for looping effect
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
