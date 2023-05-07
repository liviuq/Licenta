import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SensorRoute extends StatefulWidget {
  const SensorRoute(
      {super.key,
      required String address,
      required int id,
      required String type});

  @override
  State<SensorRoute> createState() => _SensorRouteState();
}

class _SensorRouteState extends State<SensorRoute> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xff1c2541),
        ),
      ],
    );
  }
}
