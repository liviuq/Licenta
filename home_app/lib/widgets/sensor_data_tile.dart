import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_app/widgets/date.dart';

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
  String? location;
  TextEditingController locationContoller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        // show a dialog box to confirm deletion
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Set location of sensor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: locationContoller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Location',
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // close the dialog box
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      location = locationContoller.text;
                      locationContoller.clear();
                    });
                    // close the dialog box
                    Navigator.of(context).pop();
                    // delete the sensor
                  },
                  child: const Text('Assign'),
                )
              ],
            );
          },
        );
      },
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
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              height: 110,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                        ),
                        CircleAvatar(
                          backgroundColor: const Color(0xff6fffe9),
                          child: Text(
                            widget.address,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 20, 0),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Last sensor reading: ',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            // if the date is today, show the time, otherwise show the date
                            '${widget.value}',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DateWidget(
                            dateString: widget.date,
                          ),
                        ],
                      ),
                    ),
                    // vertical line for separation
                    const Padding(
                      padding: EdgeInsets.all(3),
                      child: VerticalDivider(
                        color: Colors.white,
                        thickness: 2,
                      ),
                    ),
                    // prints the location if it exists
                    if (location != null)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // insert an icon
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            Text(
                              location!,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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
      ),
    );
  }
}
