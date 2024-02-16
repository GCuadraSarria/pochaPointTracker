import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:provider/provider.dart';

import '../../provider/provider.dart';
import '../../widgets/widgets.dart';

class Test extends StatelessWidget {
  const Test({super.key});

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
              padding:
                  EdgeInsets.symmetric(vertical: 24.0, horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // restart and menu buttons

                  Text(
                    '100',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  Text(
                    '200',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    '300',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    '400',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
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
