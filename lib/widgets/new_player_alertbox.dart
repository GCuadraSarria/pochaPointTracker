import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/services/firestore.dart';
import 'package:pocha_points_tracker/theme/theme.dart';
import 'package:pocha_points_tracker/widgets/widgets.dart';

class NewPlayerAlertbox extends StatefulWidget {
  const NewPlayerAlertbox({super.key});

  @override
  NewPlayerAlertboxState createState() => NewPlayerAlertboxState();
}

class NewPlayerAlertboxState extends State<NewPlayerAlertbox> {
  // textfield controller
  TextEditingController textController = TextEditingController();

  // enable / disable custom button based on textfield not empty
  bool isDisabled = true;

  // show error message if player exists
  bool playerExists = false;

  // firestore service
  final FirestoreService firestoreService = FirestoreService();

  // capitalize first letter of a string
  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }

    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: CustomColors.backgroundColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Nuevo jugador',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            iconSize: 32.0,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: textController,
            maxLength: 12,
            onChanged: (value) {
              setState(() {
                // Enable the button if there is text in the input
                isDisabled = value.isEmpty;

                // clear validator text
                playerExists = false;
              });
            },
            decoration: InputDecoration(
              hintText: 'Nombre del jugador',
              hintStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                color: CustomColors.bgGradient3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              fillColor: CustomColors.whiteColor,
              counterText: '',
            ),
          ),
          playerExists
              ? const Text(
                  'Ya existe un jugador con ese nombre',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: CustomColors.errorColor,
                  ),
                )
              : const Text(''),
        ],
      ),
      actions: [
        CustomButton(
          onPressed: () async {
            // if player already exists
            if (await firestoreService
                .doesPlayerExist(capitalizeFirstLetter(textController.text))) {
              setState(() {
                // disable button and show error text
                isDisabled = true;
                playerExists = true;
              });
            } else {
              // Add the new player to Firestore
              await firestoreService
                  .addPlayer(capitalizeFirstLetter(textController.text));

              // Clear textfield
              textController.clear();

              // Close alert
              Navigator.pop(context);
            }
          },
          text: 'Agregar jugador',
          width: 323.0,
          // Use the isDisabled state to enable/disable the button
          isDisabled: isDisabled,
        ),
      ],
    );
  }
}
