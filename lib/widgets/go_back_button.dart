import 'package:flutter/material.dart';

import '../theme/theme.dart';

class GoBackButton extends StatelessWidget {
  final String btnText;
  const GoBackButton({
    super.key,
    this.btnText = 'Atrás',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          btnText,
          style: const TextStyle(
            decoration: TextDecoration.underline,
            decorationColor: CustomColors.whiteColor,
            color: CustomColors.whiteColor,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
