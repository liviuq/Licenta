import 'package:flutter/material.dart';
import 'package:home_app/widgets/sensor_data_tile.dart';

import '../utils/fetch.dart';

class SensorAddress extends StatefulWidget {
  final String type;

  const SensorAddress({
    super.key,
    required this.type,
  });

  @override
  State<SensorAddress> createState() => _SensorAddressState();
}

class _SensorAddressState extends State<SensorAddress> {
  late Future<List> sensorAddressesFromTypeFuture;

  @override
  void initState() {
    super.initState();
    sensorAddressesFromTypeFuture = getSensorAddressesFromType(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: sensorAddressesFromTypeFuture,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          // Create widgets using the data in the snapshot
          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: snapshot.data?.length,
            itemBuilder: (BuildContext context, int index) {
              // in SensorCategory you can query for the /snapshot.data![index]/addresses
              // to list the addresses and then to display the cards
              return SensorDataTile(
                icon: Icons.sensors,
                type: widget.type,
                address: snapshot.data![index],
                switchValue: true,
                onSwitchChange: (value) {},
                sliderValue: 0,
                onSliderChange: (value) {},
                onTap: () {},
              );
            },
          );
        } else {
          // Show loading indicator while waiting for data
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
