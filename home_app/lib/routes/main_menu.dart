import 'package:flutter/material.dart';
import 'package:home_app/widgets/sensor_category.dart';
import 'package:home_app/widgets/sensor_data_tile.dart';

import '../models/sensor.dart';
import '../utils/fetch.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // list with Sensors to display on main menu screen
  Future<List> _sensors = getSensorsFuture();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xff0f082c),
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
                      _sensors = getSensorsFuture();
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
                            onTap: () {},
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
                        onTap: () {},
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
