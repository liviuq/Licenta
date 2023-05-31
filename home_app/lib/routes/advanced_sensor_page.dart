import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/fetch.dart';
import '../widgets/advanced_sensor_data_tile.dart';

class AdvancedSensorRoute extends StatefulWidget {
  final String ip;
  final String name;
  final String endpoints;

  const AdvancedSensorRoute({
    super.key,
    required this.ip,
    required this.name,
    required this.endpoints,
  });

  @override
  State<AdvancedSensorRoute> createState() => _AdvancedSensorRouteState();
}

class _AdvancedSensorRouteState extends State<AdvancedSensorRoute> {
  List<String> endpoints = [];

  @override
  void initState() {
    super.initState();
    // clean the string
    String cleanedString = widget.endpoints.replaceAll('"', '');
    cleanedString = cleanedString.replaceAll('\'', '"');
    endpoints = List<String>.from(json.decode(cleanedString));
    //endpoints = jsonDecode(cleanedString).cast<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff0f082c),
            Colors.blue,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdvancedSensorDataTile(
                icon: Icons.broadcast_on_home_rounded,
                ip: widget.ip,
                name: widget.name,
                endpoints: widget.endpoints,
                date: DateTime.now().toString(),
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: FloatingActionButton.extended(
                  key: UniqueKey(),
                  heroTag: UniqueKey(),
                  label: Text(
                    'List of endpoints',
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xffe5e5e5),
                  foregroundColor: const Color(0xff003049),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  onPressed: null,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: endpoints.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  // if the found a new category name, update it
                  // and return a widget with the respective category
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FloatingActionButton.extended(
                      key: UniqueKey(),
                      heroTag: UniqueKey(),
                      label: Text(
                        endpoints[index],
                      ),
                      backgroundColor: const Color(0xffe5e5e5),
                      foregroundColor: const Color(0xff003049),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      icon: const Icon(
                        Icons.info_outlined,
                        size: 24.0,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        makeGetRequest(
                          widget.ip,
                          endpoints[index],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
