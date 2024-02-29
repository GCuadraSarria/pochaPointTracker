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
  // local india state
  late bool localIndiaState;
  // local round state
  late int localRoundState;

  @override
  void initState() {
    super.initState();
    localIndiaState = context.read<CurrentPlayers>().wePlayIndia;
    localRoundState = context.read<CurrentPlayers>().maxCards;
  }

  @override
  Widget build(BuildContext context) {
    // provider service
    final currentPlayersProvider = context.read<CurrentPlayers>();
    // india initial state
    bool initialPlayWithIndiaState = currentPlayersProvider.wePlayIndia;
    // round initial state
    int initialRoundState = currentPlayersProvider.maxCards;

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
            child: Padding(
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
                            color: CustomColors.whiteColor,
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
                            color: CustomColors.whiteColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // round selector
                  SizedBox(
                    height: 75.0,
                    width: 250.0,
                    child: HorizontalNumberSelectorConfig(
                        initialRoundState: initialRoundState,
                        onChanged: (int value) {
                          setState(() {
                            localRoundState = value;
                          });
                        }),
                  ),
                  const SizedBox(height: 24.0),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        child: Text(
                          '¿Queréis jugar la mano ciega?',
                          style: TextStyle(
                            color: CustomColors.whiteColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // india radio buttons
                  RadioButtons(
                    initialPlayWithIndiaState: initialPlayWithIndiaState,
                    onChanged: (bool value) {
                      setState(() {
                        localIndiaState = value;
                      });
                    },
                  ),
                  const Spacer(),

                  // back and next buttons
                  const GoBackButton(btnText: 'Cancelar'),
                  CustomButton(
                    text: 'Guardar Cambios',
                    width: 340.0,
                    onPressed: () {
                      // apply changes based on the desired variables
                      currentPlayersProvider.setPlayWithIndia(localIndiaState);
                      currentPlayersProvider.setMaxCards(localRoundState);
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
      ),
    );
  }
}

// horizontal scroll class
class HorizontalNumberSelectorConfig extends StatefulWidget {
  final int initialRoundState;
  final ValueChanged<int> onChanged;
  const HorizontalNumberSelectorConfig({
    super.key,
    required this.initialRoundState,
    required this.onChanged,
  });

  @override
  State<HorizontalNumberSelectorConfig> createState() =>
      _HorizontalNumberSelectorConfigState();
}

// List of posible rounds
List<int> roundList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

class _HorizontalNumberSelectorConfigState
    extends State<HorizontalNumberSelectorConfig> {
  @override
  Widget build(BuildContext context) {
    return ScrollSnapList(
      initialIndex: widget.initialRoundState.toDouble() - 1,
      itemBuilder: _buildItemList,
      itemCount: roundList.length,
      itemSize: 60.0,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      dynamicItemSize: true,
      onItemFocus: (index) {
        // modify rounds based on the selection
        widget.onChanged(roundList[index]);
      },
      dynamicItemOpacity: 0.4,
      curve: Curves.ease,
    );
  }
}

Widget _buildItemList(BuildContext context, int index) {
  return SizedBox(
    width: 60.0,
    child: Center(
      child: Text(
        '${roundList[index]}',
        style: const TextStyle(
          color: CustomColors.whiteColor,
          fontSize: 50.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

// radio button widget for india
class RadioButtons extends StatefulWidget {
  final bool? initialPlayWithIndiaState;
  final ValueChanged<bool> onChanged;
  const RadioButtons({
    super.key,
    required this.initialPlayWithIndiaState,
    required this.onChanged,
  });

  @override
  State<RadioButtons> createState() => _RadioButtonsState();
}

class _RadioButtonsState extends State<RadioButtons> {
  late bool _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialPlayWithIndiaState!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Sí'),
          leading: Radio(
            value: true,
            groupValue: _selectedValue,
            onChanged: (bool? value) {
              setState(() {
                _selectedValue = value!;
                widget.onChanged(true);
              });
            },
          ),
        ),
        ListTile(
          title: const Text('No'),
          leading: Radio(
            value: false,
            groupValue: _selectedValue,
            onChanged: (bool? value) {
              setState(() {
                _selectedValue = value!;
                widget.onChanged(false);
              });
            },
          ),
        ),
      ],
    );
  }
}
