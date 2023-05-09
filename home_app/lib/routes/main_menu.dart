import 'package:flutter/material.dart';
import 'package:home_app/widgets/sensor_category.dart';
import 'package:home_app/widgets/sensor_data_tile.dart';

import '../models/sensor.dart';
import '../utils/fetch.dart';
import 'sensor_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // bool to force a server fetch instead of a local fetch
  bool forceServerFetch = true;

  // list with Sensors to display on main menu screen
  late Future<List> _sensors;

  @override
  void initState() {
    // upon initialization, get the sensors from the server
    _sensors = getSensorsFuture(forceServerFetch: true);

    // set forceServerFetch to false so that the next time
    // the data is loaded locally
    forceServerFetch = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xff1c2541),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.grey,
            toolbarHeight: 50,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
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
          body: FutureBuilder(
            future: _sensors,
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                // reassign snapshot.data to a list of sensors
                List<Sensor> sensors = snapshot.data;

                // sort the list based on type
                sensors.sort((a, b) => a.type.compareTo(b.type));

                // declare current type
                String type = '';

                // if we discover a new sensor type, create the category
                // and return the sensors of that category
                return ListView.builder(
                  itemCount: sensors.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    // if the found a new category name, update it
                    // and return a widget with the respective category
                    if (sensors[index].type != type) {
                      type = sensors[index].type;
                      return Column(
                        children: [
                          SensorCategory(
                            title: sensors[index].type,
                          ),
                          SensorDataTile(
                            icon: Icons.broadcast_on_home_rounded,
                            address: sensors[index].address,
                            date: sensors[index].date,
                            id: sensors[index].id,
                            type: sensors[index].type,
                            value: sensors[index].value,
                            // opens a new page with the sensor data
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SensorRoute(
                                    address: sensors[index].address,
                                    id: sensors[index].id,
                                    type: sensors[index].type,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    } else {
                      return SensorDataTile(
                        icon: Icons.broadcast_on_home_rounded,
                        address: sensors[index].address,
                        date: sensors[index].date,
                        id: sensors[index].id,
                        type: sensors[index].type,
                        value: sensors[index].value,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SensorRoute(
                                address: sensors[index].address,
                                id: sensors[index].id,
                                type: sensors[index].type,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              }
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                label: 'About',
              ),
            ],
            //currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.blue,
            backgroundColor: const Color(0xff0f082c),
            onTap: (parameter) {},
          ),
        ),
      ],
    );
  }
}
