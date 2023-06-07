import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../models/sensor.dart';
import '../utils/fetch.dart';
import '../widgets/threshold_button.dart';

class SensorRoute extends StatefulWidget {
  final String address;
  final int id;
  final String type;

  const SensorRoute({
    super.key,
    required this.address,
    required this.id,
    required this.type,
  });

  @override
  State<SensorRoute> createState() => _SensorRouteState();
}

class _SensorRouteState extends State<SensorRoute> {
  // data for the chart
  late List<FlSpot> line;

  // interval for the chart
  double minY = 0, maxY = 0;
  double minX = 0, maxX = 0;

  // slider to change the granularity of the chart
  // default is 10
  late double sliderValue = 10;

  // threshold value
  late double threshold;
  final thresholdController = TextEditingController();

  // data points from server based on the slider ammount
  late Future<List<Sensor>> _data;

  @override
  void initState() {
    // load sensor data from server
    _data = getSensorDataFuture(widget.type, widget.address, sliderValue);

    // load threshold from database
    setThresholdFromDatabase(
      boxName: widget.address,
    );
    // regenerate the graph line
    line = List.generate(8, (index) {
      return FlSpot(index.toDouble(), index * Random().nextDouble());
    });
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
          toolbarHeight: 50,
          actions: [
            ThresholdButton(
                text: 'Customize threshold',
                onPressed: () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Set threshold for ${widget.address}'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: thresholdController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Value',
                                ),
                              )
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // close the dialog box
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  // open the box for the sensor with this address
                                  Hive.openBox(widget.address);

                                  // add the sensor location to it's database
                                  Hive.box(widget.address).put('threshold',
                                      double.parse(thresholdController.text));

                                  try {
                                    // update the location variable
                                    threshold =
                                        double.parse(thresholdController.text);
                                  } catch (e) {
                                    threshold = 0;
                                  }
                                  thresholdController.clear();
                                });

                                // close the dialog box
                                Navigator.of(context).pop();
                                // delete the sensor
                              },
                              child: const Text('Set'),
                            )
                          ],
                        );
                      },
                    );
                  });
                }),
          ],
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
                              'Advanced data for',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.type}:${widget.address}',
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
              FutureBuilder(
                future: _data,
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    // generate points here
                    List<Sensor> data = snapshot.data;

                    // generate line here
                    // X -> date
                    // Y -> value

                    line = List.generate(data.length, (index) {
                      if (data[index].value > maxY) {
                        maxY = data[index].value.toDouble();
                      }
                      if (data[index].value < minY) {
                        minY = data[index].value.toDouble();
                      }
                      return FlSpot(
                        index.toDouble(),
                        data[index].value.toDouble(),
                      );
                    });

                    // normalize minY and maxY
                    // no idea at the moment how to normalize minY and maxY

                    minX = 0;
                    maxX = data.length.toDouble();

                    return SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        height: 250,
                        width: double.infinity,
                        child: LineChart(
                          LineChartData(
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor:
                                    Colors.blueGrey.withOpacity(0.8),
                                getTooltipItems: (touchedSpots) => touchedSpots
                                    .map(
                                      (e) => LineTooltipItem(
                                        '${e.y} @ \n${data[e.x.toInt()].date}',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            minX: minX,
                            maxX: maxX,
                            minY: minY,
                            maxY: maxY * 1.2,
                            gridData: FlGridData(
                              show: false,
                              drawVerticalLine: true,
                              horizontalInterval: 1,
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey,
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Colors.grey,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Value',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Date',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border:
                                  Border.all(color: const Color(0xff37434d)),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: line,
                                isCurved: false,
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.cyan,
                                    Colors.blue,
                                  ],
                                ),
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color.fromARGB(255, 11, 211, 238),
                                      const Color.fromARGB(255, 27, 100, 159),
                                    ]
                                      ..map((color) => color.withOpacity(0.3))
                                      ..toList(),
                                  ),
                                ),
                              ),
                              LineChartBarData(
                                color: Colors.red,
                                spots: [
                                  FlSpot(minX, threshold),
                                  FlSpot((maxX - 1) / 2, threshold),
                                  FlSpot(maxX - 1, threshold),
                                ],
                                isCurved: false,
                                barWidth: 2,
                                isStrokeCapRound: true,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xff5bc0be),
                      width: 3,
                    ),
                    color: const Color(0xff00171f),
                  ),
                  child: Column(
                    children: [
                      Slider(
                        min: 0,
                        max: 300,
                        value: sliderValue,
                        label: 'Granularity',
                        thumbColor: Colors.cyan,
                        activeColor: Colors.red.withOpacity(0.5),
                        inactiveColor: Colors.cyan.withOpacity(0.15),
                        onChanged: (newSliderValue) {
                          // WILL CAUSE MULTIPLE RELOADS
                          setState(() {
                            sliderValue = newSliderValue;
                          });
                        },
                        // onChanged is called on eery value in the interval [startValue, endValue]
                        // so just in onChangeEnd we call the API, it will make just 1 call
                        // instead of abs(startValue - endValue) calls
                        onChangeEnd: (newSliderValue) {
                          setState(() {
                            // setting the new granularity
                            sliderValue = newSliderValue;

                            // retrieve sliderValue data points from server
                            _data = getSensorDataFuture(
                                widget.type, widget.address, sliderValue);

                            // regenerate the graph line
                            line = List.generate(8, (index) {
                              return FlSpot(index.toDouble(),
                                  index * Random().nextDouble());
                            });
                          });
                        },
                      ),
                      Text(
                        'Fetching ${sliderValue.toInt()} data points',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setThresholdFromDatabase({
    required String boxName,
  }) {
    // get the box
    final box = Hive.box(boxName);

    if (box.containsKey('threshold')) {
      setState(() {
        threshold = box.get('threshold') as double;
      });
    } else {
      setState(() {
        threshold = 0;
      });
    }
  }
}
