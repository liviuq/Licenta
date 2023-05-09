import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/sensor.dart';
import 'package:http/http.dart' as http;

Future<Sensor> fetchData() async {
  final response =
      await http.get(Uri.parse('https://andr3w.ddns.net/latest/1'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    // ignore: avoid_print
    print(jsonDecode(response.body));
    return Sensor.fromJson(jsonDecode(response.body)[0]);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load sensor data');
  }
}

Future<List<String>> getSensorTypes() async {
  final response = await http.get(Uri.parse('https://andr3w.ddns.net/types'));

  if (response.statusCode == 200) {
    // parsing the data
    var typesJson = jsonDecode(response.body)['types'];

    // creating the list
    List<String> types =
        typesJson != null ? List.from(typesJson) : List.empty();

    // return the list
    return types;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load sensor data');
  }
}

Future<List<String>> getSensorAddressesFromType(String type) async {
  final response =
      await http.get(Uri.parse('https://andr3w.ddns.net/$type/addresses'));

  if (response.statusCode == 200) {
    // parsing the data
    var typesJson = jsonDecode(response.body)['addresses'];

    // creating the list
    List<String> addresses =
        typesJson != null ? List.from(typesJson) : List.empty();

    // return the list
    return addresses;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load sensor addresses');
  }
}

Future<Sensor> getLastSensorValueFuture({
  required String type,
  required String address,
}) async {
  final response = await http
      .get(Uri.parse('https://andr3w.ddns.net/$type/$address/latest/1'));

  if (response.statusCode == 200) {
    return Sensor.fromJson(jsonDecode(response.body)[0]);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load last sensor data');
  }
}

// get data of all sensors in one API call
Future<List<Sensor>> getSensorsFuture({required bool forceServerFetch}) async {
  // open the box
  var box = await Hive.openBox<List>('home_page_data');

  if (forceServerFetch) {
    final response =
        await http.get(Uri.parse('https://andr3w.ddns.net/sensors'));

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body);

      List<Sensor> sensorList = [];

      for (var json in jsonList) {
        sensorList.add(Sensor.fromJson(json));
      }

      // adding the list to the database
      await box.put('cards', sensorList);

      // return the data
      return sensorList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load last sensor data');
    }
  } else {
    // check if the data is in the box
    if (box.containsKey('cards')) {
      // return the data
      List<Sensor> cards = box.get('cards')!.cast();

      return Future<List<Sensor>>.value(cards);
    }
  }
  throw Exception('Failed to load last sensor data: thrown at the end');
}

Future<List<Sensor>> getSensorDataFuture(
    String type, String address, double sliderValue) async {
  final response = await http.get(Uri.parse(
      'https://andr3w.ddns.net/$type/$address/latest/${sliderValue.toInt()}'));

  if (response.statusCode == 200) {
    final jsonList = jsonDecode(response.body);

    List<Sensor> sensorList = [];

    for (var json in jsonList) {
      sensorList.add(Sensor.fromJson(json));
    }

    return sensorList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load last sensor data');
  }
}
