import 'package:flutter/material.dart';

class SensorDataTile extends StatefulWidget {
  final IconData icon;
  final String address;
  final String date;
  final int id;
  final String type;
  final int value;
  final void Function()? onTap;

  final Color textColor;

  const SensorDataTile({
    super.key,
    required this.icon,
    required this.address,
    required this.date,
    required this.id,
    required this.type,
    required this.value,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  State<SensorDataTile> createState() => _SensorDataTileState();
}

class _SensorDataTileState extends State<SensorDataTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
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
                            // Create widgets using the data in the snapshot
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address: ${widget.address}',
                                ),
                                Text(
                                  'Type: ${widget.type}',
                                ),
                                Text(
                                  'Current value: ${widget.value}',
                                ),
                                Text(
                                  'Last update: \n${widget.date}',
                                ),
                              ],
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
