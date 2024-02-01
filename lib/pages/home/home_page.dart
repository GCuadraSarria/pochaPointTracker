import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/widgets/custom_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                Container(
                    height: 213.0,
                    width: 213.0,
                    color: const Color(0xFFD9D9D9)),
                const SizedBox(height: 67.0),
                CustomButton(
                  text: 'Iniciar partida',
                  width: 294.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SelectPlayersPage()),
                    );
                  },
                ),
                const SizedBox(height: 20.0),
                CustomButton(
                  text: 'Configurar partida',
                  width: 294.0,
                  isFilled: false,
                  onPressed: () {
                    print('Click');
                  },
                ),
                const SizedBox(height: 20.0),
                CustomButton(
                  text: 'Ranking',
                  width: 294.0,
                  isFilled: false,
                  onPressed: () {
                  //  Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const BazGameplayPage()),
                  //   );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
