import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SensorCategory extends StatelessWidget {
  final String title;
  final Color textColor;

  const SensorCategory({
    super.key,
    required this.title,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xff5bc0be),
                width: 3,
              ),
              color: const Color(0xff5bc0be),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                title,
                style: GoogleFonts.roboto(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
