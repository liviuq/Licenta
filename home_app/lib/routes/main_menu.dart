import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:home_app/models/advanced_sensor.dart';
import 'package:home_app/widgets/sensor_category.dart';
import 'package:home_app/widgets/sensor_data_tile.dart';
import 'package:intl/intl.dart';

import '../models/sensor.dart';
import '../utils/fetch.dart';
import '../widgets/advanced_sensor_data_tile.dart';
import 'about.dart';
import 'advanced_sensor_page.dart';
import 'logs.dart';
import 'sensor_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // secure mode variable
  late bool _secureMode = false;

  // bool to force a server fetch instead of a local fetch
  bool forceServerFetch = true;

  // list with Sensors to display on main menu screen
  late Future<List<List>> _sensors;

  final List<Widget> _screens = const [
    LogsRoute(),
    AboutRoute(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _screens[index]),
      );
    });
  }

  @override
  void initState() {
    // upon initialization, get the sensors from the server
    _sensors = getSensorsFuture(forceServerFetch: true);

    // get the secure mode from the box
    setSecureModeFromDatabase(
      boxName: 'settings',
    );

    // set forceServerFetch to false so that the next time
    // the data is loaded locally
    forceServerFetch = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xff0f082c),
            _secureMode == true ? Colors.red : Colors.blue,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          toolbarHeight: 50,
          actions: [
            Row(
              children: [
                Text(
                  'Left home?',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  value: _secureMode,
                  onChanged: (bool value) {
                    setState(() {
                      _secureMode = value;

                      // save the secure mode to the box
                      // so that it can be retrieved later
                      saveSecureModeToDatabase(
                        boxName: 'settings',
                        timeStamp: DateTime.now().toString(),
                        value: value,
                      );
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Reload data',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: InkWell(
                    splashColor: Colors.blue, // optional splash color
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(100.0),
                    onTap: () {
                      setState(() {
                        // force fetching from the server
                        _sensors = getSensorsFuture(
                          forceServerFetch: true,
                        );
                      });
                    },
                    child: const Icon(
                      Icons.replay,
                      size: 26.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: FutureBuilder(
          future: _sensors,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              // reassign snapshot.data to a list of sensors
              List<Sensor> staticSensors = snapshot.data[0];
              List<AdvancedSensor> advancedSensors = snapshot.data[1];

              // list of widgets to create using listview.builder
              List<Widget> widgets = [];

              // sort the list based on type
              staticSensors.sort((a, b) => a.type.compareTo(b.type));

              // declare current type
              String type = '';
              for (var sensor in staticSensors) {
                if (sensor.type != type) {
                  type = sensor.type;
                  widgets.add(
                    Column(
                      children: [
                        SensorCategory(
                          title: sensor.type,
                          textColor: Colors.black,
                        ),
                        SensorDataTile(
                          icon: Icons.broadcast_on_home_rounded,
                          address: sensor.address,
                          date: sensor.date,
                          id: sensor.id,
                          type: sensor.type,
                          value: sensor.value,
                          // opens a new page with the sensor data
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SensorRoute(
                                  address: sensor.address,
                                  id: sensor.id,
                                  type: sensor.type,
                                ),
                              ),
                            );
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  widgets.add(
                    SensorDataTile(
                      icon: Icons.broadcast_on_home_rounded,
                      address: sensor.address,
                      date: sensor.date,
                      id: sensor.id,
                      type: sensor.type,
                      value: sensor.value,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SensorRoute(
                              address: sensor.address,
                              id: sensor.id,
                              type: sensor.type,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }

              if (advancedSensors.isNotEmpty) {
// add the separator for the advanced sensors
                widgets.add(
                  const Center(
                    child: SensorCategory(
                      title: 'Advanced',
                      textColor: Colors.black,
                    ),
                  ),
                );
              }
              for (var sensor in advancedSensors) {
                DateFormat dateFormat =
                    DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
                DateTime dateTime = dateFormat.parse(sensor.date);
                // if difference is less than 6 hours, add it to the list
                if (DateTime.now().difference(dateTime).inHours < 6) {
                  widgets.add(
                    AdvancedSensorDataTile(
                      icon: Icons.broadcast_on_home_rounded,
                      ip: sensor.ip,
                      name: sensor.name,
                      endpoints: sensor.endpoints,
                      date: sensor.date,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdvancedSensorRoute(
                              ip: sensor.ip,
                              name: sensor.name,
                              endpoints: sensor.endpoints,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }
              // if we discover a new sensor type, create the category
              // and return the sensors of that category
              return ListView.builder(
                itemCount: widgets.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  // if the found a new category name, update it
                  // and return a widget with the respective category
                  return widgets[index];
                },
              );
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'About',
            ),
          ],
          // same color because those are not meant
          // to be selected (sorry Material Design Guidelines)
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.blue,
          backgroundColor: const Color(0xff0f082c),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void setSecureModeFromDatabase({
    required String boxName,
  }) async {
    // open the box
    await Hive.openBox(boxName);
    var box = Hive.box(boxName);

    // check for secureMode key
    if (box.containsKey('secureMode')) {
      setState(() {
        _secureMode = box.get('secureMode') as bool;
      });
    } else {
      setState(() {
        _secureMode = false;
      });
    }
  }

  void saveSecureModeToDatabase({
    required String boxName,
    required bool value,
    required String timeStamp,
  }) async {
    // open the box
    await Hive.openBox(boxName);
    var box = Hive.box(boxName);

    // save the value
    box.put('secureMode', value);
    box.put('timeStamp', timeStamp);
  }
}
