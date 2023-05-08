import 'package:flutter/material.dart';

import 'package:home_app/utils/fetch.dart';

import 'sensor_data_tile.dart';

class SensorList extends StatefulWidget {
  const SensorList({super.key});

  @override
  State<SensorList> createState() => _SensorListState();
}

class _SensorListState extends State<SensorList> {
  late Future<List> allData;

  @override
  void initState() {
    allData = getSensorsFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: allData,
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
                type: snapshot.data![index],
                address: snapshot.data![index],
                onTap: () {},
                date: '',
                id: 1,
                value: 1,
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
