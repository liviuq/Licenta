import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThresholdButton extends StatefulWidget {
  final String text;
  final Function onPressed;
  const ThresholdButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<ThresholdButton> createState() => _ThresholdButtonState();
}

class _ThresholdButtonState extends State<ThresholdButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          widget.text,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
