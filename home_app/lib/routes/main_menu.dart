import 'package:flutter/material.dart';

// ignore: unused_import
import '../models/sensor.dart';
// ignore: unused_import
import '../utils/dummy_fetch.dart';
import '../widgets/custom_list_tile.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // to display sensors based on categories
  Future<List> sensorTypes = getSensorTypes();

  //
  bool switchValue = false;
  double sliderValue = 0;
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
            toolbarHeight: 30,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: 3,
            itemBuilder: (context, index) => CustomListTile(
              icon: Icons.home_rounded,
              title: 'Ground floor',
              subtitle: 'All lights on',
              switchValue: switchValue,
              onSwitchChange: (newSwitchValue) {
                setState(() {
                  switchValue = newSwitchValue;
                });
              },
              sliderValue: sliderValue,
              onSliderChange: (newSliderValue) {
                setState(() {
                  sliderValue = newSliderValue;
                });
              },
              onTap: () {
                // ignore: avoid_print
                print('GO TO THE DETAILS PAGE');
              },
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Business',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'School',
              ),
            ],
            //currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: (parameter) {},
          ),
        ),
      ],
    );
  }
}
