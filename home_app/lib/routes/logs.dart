import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:home_app/models/sensor.dart';
import 'package:intl/intl.dart';

import '../utils/fetch.dart';
import '../widgets/sensor_data_tile.dart';

class LogsRoute extends StatefulWidget {
  const LogsRoute({super.key});

  @override
  State<LogsRoute> createState() => _LogsRouteState();
}

class _LogsRouteState extends State<LogsRoute> {
  // sensor list
  late Future<List<Sensor>> _sensorData;

  // list of widgets to be displayed
  List<Widget> widgets = [];

  // IMPLEMENT LEFT HOME CHECK
  // secure mode variable
  late bool _secureMode = false;
  late DateTime _lastLeftHome = DateTime.now();

  @override
  void initState() {
    // get all resultCount sensor data points
    _sensorData = fetchSensorData(resultCount: 100);

    getSecureModeFromDatabase(
      boxName: 'settings',
    );
    super.initState();
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
        // if the secure mode is on, display the logs
        // else display that secure mode is off to
        // avoid getting data from the server
        // when secure mode is off
        body: getLogsOrNotification(),
      ),
    );
  }

  double getThresholdFromDatabase({
    required String boxName,
  }) {
    // get the box
    final box = Hive.box(boxName);

    if (box.containsKey('threshold')) {
      return box.get('threshold') as double;
    } else {
      return 0;
    }
  }

  void getSecureModeFromDatabase({
    required String boxName,
  }) async {
    // open the box
    await Hive.openBox(boxName);
    var box = Hive.box(boxName);

    // check for secureMode key
    if (box.containsKey('secureMode')) {
      setState(() {
        _secureMode = box.get('secureMode') as bool;
        _lastLeftHome = DateTime.parse(box.get('timeStamp'));
      });
    } else {
      setState(() {
        _secureMode = false;
      });
    }
  }

  getLogsOrNotification() {
    if (_secureMode) {
      return FutureBuilder<List<Sensor>>(
        future: _sensorData,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final sensorList = snapshot.data as List<Sensor>;
            final List<String> uniqueAddresses = [];
            for (final sensor in sensorList) {
              if (!uniqueAddresses.contains(sensor.address)) {
                uniqueAddresses.add(sensor.address);
              }
            }

            // get all thresholds for each address
            final List<double> thresholds = [];
            for (final address in uniqueAddresses) {
              thresholds.add(getThresholdFromDatabase(boxName: address));
            }

            // create the map of address and threshold
            Map<String, double> addressThresholdMap =
                Map.fromIterables(uniqueAddresses, thresholds);

            // create custom date format
            DateFormat dateFormat =
                DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");

            for (var sensor in sensorList) {
              if (sensor.value <= addressThresholdMap[sensor.address]! &&
                  (dateFormat.parse(sensor.date).add(const Duration(hours: 3)))
                      .isAfter(_lastLeftHome)) {
                widgets.add(
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          // if the value is greater than the threshold, change the color
                          color: Colors.red,

                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'WARN',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SensorDataTile(
                        icon: Icons.broadcast_on_home_rounded,
                        address: sensor.address,
                        date: sensor.date,
                        id: sensor.id,
                        type: sensor.type,
                        value: sensor.value,
                        onTap: () => {},
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                    ],
                  ),
                );
              }
            }
            if (widgets.isEmpty) {
              return Center(
                child: FloatingActionButton.extended(
                  key: UniqueKey(),
                  heroTag: UniqueKey(),
                  label: Text(
                    'No warnings',
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
              );
            } else {
              return ListView.builder(
                itemCount: widgets.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return widgets[index];
                },
              );
            }
          }
        },
      );
    } else {
      return Center(
        child: FloatingActionButton.extended(
          key: UniqueKey(),
          heroTag: UniqueKey(),
          label: Text(
            'Secure mode is off',
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
      );
    }
  }
}
