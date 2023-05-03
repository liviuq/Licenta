import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/sensor.dart';
import '../utils/fetch.dart';

class SensorDataTile extends StatefulWidget {
  final IconData icon;
  final String type;
  final String address;
  final bool switchValue;
  final void Function(bool)? onSwitchChange;
  final double sliderValue;
  final void Function(double)? onSliderChange;
  final void Function()? onTap;

  final Color textColor;

  const SensorDataTile({
    super.key,
    required this.icon,
    required this.type,
    required this.address,
    required this.switchValue,
    required this.onSwitchChange,
    required this.sliderValue,
    required this.onSliderChange,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  State<SensorDataTile> createState() => _SensorDataTileState();
}

class _SensorDataTileState extends State<SensorDataTile> {
  // last sensor value
  late Future<Sensor> lastSensorValueFuture;

  @override
  void initState() {
    super.initState();
    lastSensorValueFuture =
        getLastSensorValueFuture(widget.type, widget.address);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          size: 35,
                          color: widget.textColor,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Sensor>(
                              future: lastSensorValueFuture,
                              builder: (BuildContext context,
                                  AsyncSnapshot<Sensor> snapshot) {
                                if (snapshot.hasData) {
                                  // Create widgets using the data in the snapshot
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Address: \n${snapshot.data?.address}',
                                      ),
                                      Text(
                                        'Current value: \n${snapshot.data?.value}',
                                      ),
                                      Text(
                                        'Last update: \n${snapshot.data?.date}',
                                      ),
                                    ],
                                  );
                                } else {
                                  // Show loading indicator while waiting for data
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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
