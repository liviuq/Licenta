import 'package:flutter/material.dart';

import '../utils/fetch.dart';
import '../widgets/sensor_category.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // to display sensors based on categories
  Future<List> sensorTypesFuture = getSensorTypes();

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
            toolbarHeight: 40,
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.replay,
                      size: 26.0,
                    ),
                  )),
            ],
          ),
          body: FutureBuilder<List>(
            future: sensorTypesFuture,
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                // Create widgets using the data in the snapshot
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    // in SensorCategory you can query for the /snapshot.data![index]/addresses
                    // to list the addresses and then to display the cards
                    return SensorCategory(
                      title: '${snapshot.data![index]}',
                    );
                  },
                );
              } else {
                // Show loading indicator while waiting for data
                return const CircularProgressIndicator();
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
