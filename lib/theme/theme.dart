import 'package:flutter/material.dart';

class CustomColors {
  static const Color backgroundColor = Color(0xFF1D1D1D);
  static const Color primaryColor = Color(0xFF7E2DD9);
  static const Color secondaryColor = Color(0xFFB640FF);
  static const Color terciaryColor = Color(0xFF2196F3);
  static const Color correctColor = Color(0xFF2ED92E);
  static const Color errorColor = Color(0xFFE95A5A);
  static const Color whiteColor = Color(0xFFFFFCFC);
  // gradient backgrounds
  static const Color bgGradient1 = Color(0xFF4F4F4F);
  static const Color bgGradient2 = Color(0xFF939393);
  static const Color bgGradient3 = Color(0xFFBFBFBF);
  static const Color bgGradient4 = Color(0xFFE0E0E0);
  // linear gradients
  static const LinearGradient shadowGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 255, 255, 0.00),
      Color.fromRGBO(255, 255, 255, 0.35),
      Color.fromRGBO(255, 255, 255, 1.00),
      Color.fromRGBO(255, 255, 255, 0.35),
      Color.fromRGBO(255, 255, 255, 0.00),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
