import 'package:flutter/material.dart';

class GoBackButton extends StatelessWidget {
  final String btnText;
  const GoBackButton({
    super.key,
    this.btnText = 'Atrás',
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        btnText,
        style: const TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
