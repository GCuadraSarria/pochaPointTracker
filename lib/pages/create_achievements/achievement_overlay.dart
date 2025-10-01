import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:pocha_points_tracker/theme/theme.dart';

class AchievementOverlay extends StatefulWidget {
  final String name;
  final String achievementName;
  final String achievementDescription;
  final VoidCallback onClose;
  const AchievementOverlay({
    required this.name,
    required this.achievementName,
    required this.achievementDescription,
    required this.onClose,
    super.key,
  });

  @override
  State<AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends State<AchievementOverlay>
    with TickerProviderStateMixin {
  late final AnimationController lottieController;
  bool animationEnded = false;
  bool showTexts = false;

  @override
  void initState() {
    super.initState();
    lottieController = AnimationController(vsync: this);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showTexts = true);
    });
  }

  @override
  void dispose() {
    lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: animationEnded ? widget.onClose : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      child: Text(
                        widget.achievementName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: CustomColors.whiteColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Lottie.asset(
                      'lib/assets/lottie/trophy.json',
                      repeat: false,
                      controller: lottieController,
                      onLoaded: (composition) {
                        lottieController.duration = composition.duration;
                        lottieController.forward().whenComplete(() {
                          setState(() {
                            if (mounted) setState(() => animationEnded = true);
                          });
                        });
                      },
                    ),
                    AnimatedOpacity(
                      opacity: showTexts ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '${widget.name} ha conseguido:\n${widget.achievementDescription}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CustomColors.whiteColor,
                          fontSize: 22.0,
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
      ),
    );
  }
}
