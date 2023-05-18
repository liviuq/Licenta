import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../utils/fetch.dart';

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
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xff5bc0be),
                          width: 3,
                        ),
                        color: const Color(0xff00171f),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Advanced options for',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.ip,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.name,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: endpoints.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    // if the found a new category name, update it
                    // and return a widget with the respective category
                    return FloatingActionButton.extended(
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void makeGetRequest(String ip, String endpoint) async {
    // Create the URL with parameters
    String url =
        'https://andr3w.ddns.net/advanced/request?ip=$ip&endpoint=$endpoint';

    // Make the GET request
    final response = await http.get(Uri.parse(url));

    // Handle the response
    if (response.statusCode == 200) {
      // Successful GET request
      print('GET request successful');
      print('Response body: ${response.body}');
    } else {
      // Error in GET request
      print(
          'Error: GET request failed with status code ${response.statusCode}');
    }
  }
}
