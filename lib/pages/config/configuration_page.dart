import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/pages/pages.dart';
import 'package:pocha_points_tracker/provider/provider.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  @override
  Widget build(BuildContext context) {
    // provider service
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      Text(
                        'Configurar partida',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        '¿Cuántas rondas queréis jugar?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                // round selector
                const SizedBox(
                    height: 75.0,
                    width: 250.0,
                    child: HorizontalNumberSelector()),
                const SizedBox(height: 24.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        '¿Queréis jugar la mano ciega?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const RadioButtons(),
                const Spacer(),

                // back and next buttons
                GoBackButton(btnText: 'Cancelar'),
                CustomButton(
                  text: 'Guardar Cambios',
                  width: 340.0,
                  onPressed: () {
                    //TODO: Apply changes based on the desired variables
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
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

// horizontal scroll class
class HorizontalNumberSelector extends StatefulWidget {
  const HorizontalNumberSelector({super.key});

  @override
  State<HorizontalNumberSelector> createState() =>
      _HorizontalNumberSelectorState();
}

// List of posible rounds
List<int> roundList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

class _HorizontalNumberSelectorState extends State<HorizontalNumberSelector> {
  @override
  Widget build(BuildContext context) {
    final currentPlayersProvider = context.read<CurrentPlayers>();
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          height: 50,
          width: 250,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromRGBO(29, 29, 29, 1.0), // 100% opacity
                  Color.fromRGBO(29, 29, 29, 0.0), // 0% opacity
                  Color.fromRGBO(29, 29, 29, 1.0), // 100% opacity
                ]),
          ),
        ),
        ScrollSnapList(
          initialIndex: currentPlayersProvider.maxCards - 1,
          itemBuilder: _buildItemList,
          itemCount: roundList.length,
          itemSize: 50.0,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          dynamicItemSize: true,
          onItemFocus: (index) {
            // modify rounds based on the selection
            currentPlayersProvider.setMaxCards(roundList[index]);
          },
          dynamicItemOpacity: 0.4,
          curve: Curves.ease,
        ),
      ],
    );
  }
}

Widget _buildItemList(BuildContext context, int index) {
  return SizedBox(
    width: 50.0,
    child: Center(
      child: Text(
        '${roundList[index]}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 50.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

// radio button widget
enum PlayIndia { yes, no }

class RadioButtons extends StatefulWidget {
  const RadioButtons({super.key});

  @override
  State<RadioButtons> createState() => _RadioButtonsState();
}

class _RadioButtonsState extends State<RadioButtons> {
  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();
    // india play
    PlayIndia? playWithIndia =
        currentPlayersProvider.wePlayIndia ? PlayIndia.yes : PlayIndia.no;

    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Sí'),
          leading: Radio<PlayIndia>(
            value: PlayIndia.yes,
            groupValue: playWithIndia,
            onChanged: (PlayIndia? value) {
              setState(() {
                playWithIndia = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('No'),
          leading: Radio<PlayIndia>(
            value: PlayIndia.no,
            groupValue: playWithIndia,
            onChanged: (PlayIndia? value) {
              setState(() {
                playWithIndia = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
