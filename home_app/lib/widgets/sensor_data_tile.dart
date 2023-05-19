import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
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
  double height = 155;

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
                      Hive.box(widget.address)
                          .put('location', locationContoller.text);

                      // update the location variable
                      location = locationContoller.text;
                      locationContoller.clear();

                      height = 155;
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
              height: height,
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
                                widget.address,
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
                            Icon(
                              widget.icon,
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
                                'Value : ${widget.value.toString()}',
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
    var box = Hive.openBox(widget.address);
    box.whenComplete(() {
      setState(() {
        location = Hive.box(widget.address).get('location');
        if (location != null) {
          height = 155;
        } else {
          height = 125;
        }
      });
    });
  }
}
