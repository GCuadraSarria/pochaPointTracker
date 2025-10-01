import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/theme/theme.dart';

class LoadingProgress extends StatefulWidget {
  const LoadingProgress({super.key});

  @override
  State<LoadingProgress> createState() => _LoadingProgressState();
}

class _LoadingProgressState extends State<LoadingProgress> {
  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(      
      backgroundColor: CustomColors.whiteColor,
      valueColor: AlwaysStoppedAnimation(CustomColors.primaryColor),
    );
  }
}
