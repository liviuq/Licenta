import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class AdvancedSensorDataTile extends StatefulWidget {
  final IconData icon;
  final String ip;
  final String name;
  final String endpoints;
  final String date;
  final void Function()? onTap;

  final Color textColor;

  const AdvancedSensorDataTile({
    super.key,
    required this.icon,
    required this.ip,
    required this.name,
    required this.endpoints,
    required this.date,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  State<AdvancedSensorDataTile> createState() => _AdvancedSensorDataTileState();
}

class _AdvancedSensorDataTileState extends State<AdvancedSensorDataTile> {
  String? location;
  TextEditingController locationContoller = TextEditingController();

  @override
  void initState() {
    // self explanatory
    loadLocationFromBox();
    super.initState();
  }

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
                      // add the sensor location to it's database
                      Hive.box(widget.ip)
                          .put('location', locationContoller.text);

                      // update the location variable
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
            color: const Color(0xff00171f),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              height: 155,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.laptop_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: const Color(0xff6fffe9),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                widget.ip,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: const Color(0xff6fffe9),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                widget.name,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: const Color(0xff6fffe9),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                widget.date,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // prints the location if it exists
                        const Padding(
                          padding: EdgeInsets.all(4),
                        ),
                        if (location != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xff6fffe9),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  location!,
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
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

  void loadLocationFromBox() {
    var box = Hive.openBox(widget.ip);
    box.whenComplete(() {
      setState(() {
        location = Hive.box(widget.ip).get('location');
      });
    });
  }
}
