// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:pocha_points_tracker/theme/theme.dart';

class TestPage extends StatefulWidget {
  final String name;
  final String achievement;
  const TestPage({
    required this.name,
    required this.achievement,
    super.key,
  });
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with TickerProviderStateMixin {
  bool showOverlay = false;
  AnimationController? lottieController;
  bool animationEnded = false;
  bool showTexts = false;

  void showLottieOverlay(BuildContext context) {
    lottieController = AnimationController(vsync: this);
    setState(() {
      showOverlay = true;
      animationEnded = false;
      showTexts = false;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && showOverlay) {
        setState(() {
          showTexts = true;
        });
      }
    });
  }

  void hideLottieOverlay() {
    setState(() {
      showOverlay = false;
      showTexts = false;
    });
    lottieController?.dispose();
    lottieController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => showLottieOverlay(context),
                child: const Text('Lottie'),
              ),
            ],
          ),
          if (showOverlay)
            GestureDetector(
              onTap: animationEnded ? hideLottieOverlay : null,
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      color: Colors.black.withAlpha(85),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: showTexts ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: const Text(
                            'Logro desbloqueado',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: CustomColors.whiteColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Lottie.asset(
                          'lib/assets/lottie/trophy.json',
                          repeat: false,
                          controller: lottieController,
                          onLoaded: (composition) {
                            lottieController?.duration = composition.duration;
                            lottieController?.forward().whenComplete(() {
                              setState(() {
                                animationEnded = true;
                              });
                            });
                          },
                        ),
                        AnimatedOpacity(
                          opacity: showTexts ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            '${widget.name} ha conseguido ${widget.achievement}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: CustomColors.whiteColor,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w500,
                            ),
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
    );
  }
}
