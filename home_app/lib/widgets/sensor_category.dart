import 'package:flutter/material.dart';

import 'sensor_address.dart';

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
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.pink,
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        SensorAddress(
          type: title,
        ),
      ],
    );
  }
}
