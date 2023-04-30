import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/sensor.dart';
import '../utils/dummy_fetch.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  // late Future<Sensor> futureData;
  // @override
  // void initState() {
  //   super.initState();
  //   futureData = fetchData();
  // }

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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  "Home",
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: 7,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 50, 10),
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                      child: Center(
                        child: Text('Entry ${[index]}'),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 1,
                    indent: 40,
                    endIndent: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
