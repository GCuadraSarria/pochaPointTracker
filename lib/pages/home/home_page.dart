import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // provider
    final currentPlayersProvider = context.read<CurrentPlayers>();

    return SafeArea(
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
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  SvgPicture.asset('lib/assets/images/logo_pocha.svg',
                      semanticsLabel: 'logo'),
                  const SizedBox(height: 80.0),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConfigurationPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20.0),
                  CustomButton(
                    text: 'Estadísticas',
                    width: 294.0,
                    isFilled: false,
                    onPressed: () async {
                      await currentPlayersProvider.setAllPlayersList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RankingPage()),
                      );
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
