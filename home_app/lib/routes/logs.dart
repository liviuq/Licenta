import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:home_app/models/sensor.dart';

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

  @override
  void initState() {
    // get all resultCount sensor data points
    _sensorData = fetchSensorData(resultCount: 100);

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
        body: FutureBuilder<List<Sensor>>(
          future: _sensorData,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final sensorList = snapshot.data as List<Sensor>;

              // get all the unique sensor addresses from sensorList
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

              return ListView.builder(
                itemCount: sensorList.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          // if the value is greater than the threshold, change the color
                          color: sensorList[index].value <=
                                  addressThresholdMap[
                                      sensorList[index].address]!
                              ? Colors.red
                              : Colors.blue,

                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          (index + 1).toString(),
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SensorDataTile(
                        icon: Icons.broadcast_on_home_rounded,
                        address: sensorList[index].address,
                        date: sensorList[index].date,
                        id: sensorList[index].id,
                        type: sensorList[index].type,
                        value: sensorList[index].value,
                        onTap: () => {},
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
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
}
