import 'package:flutter/material.dart';
import 'package:pocha_points_tracker/theme/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final bool isFilled;
  final bool isDisabled;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    this.height = 55.0,
    this.width = 234.0,
    this.isFilled = true,
    this.isDisabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Button gradient
    LinearGradient gradient = const LinearGradient(
      colors: [
        CustomColors.primaryColor,
        CustomColors.secondaryColor,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: !isDisabled ? gradient : null,
        color: isDisabled ? CustomColors.bgGradient2 : null,
        borderRadius: BorderRadius.circular(100.0),
        boxShadow: !isDisabled
            ? const [
                BoxShadow(
                  color: CustomColors.primaryColor,
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: !isDisabled ? onPressed : null,
        style: isFilled
            ? ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
            : ElevatedButton.styleFrom(
                elevation: 0,
              ),
        child: Text(
          text,
          style: const TextStyle(
            color: CustomColors.whiteColor,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
