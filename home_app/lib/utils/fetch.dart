import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/advanced_sensor.dart';
import '../models/sensor.dart';
import 'package:http/http.dart' as http;

Future<List<Sensor>> fetchSensorData({required int resultCount}) async {
  final response =
      await http.get(Uri.parse('https://andr3w.ddns.net/latest/$resultCount'));

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
Future<List<List>> getSensorsFuture({required bool forceServerFetch}) async {
  // open the box
  var box = await Hive.openBox<List>('home_page_data');

  if (forceServerFetch) {
    final response =
        await http.get(Uri.parse('https://andr3w.ddns.net/sensors'));

    if (response.statusCode == 200) {
      // final jsonList = jsonDecode(response.body);

      // List<Sensor> sensorList = [];

      // for (var json in jsonList) {
      //   sensorList.add(Sensor.fromJson(json));
      // }

      // // adding the list to the database
      // await box.put('cards', sensorList);

      // // return the data
      // return sensorList;

      // parse the JSON string into a Map
      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      // retrieve the "advanced" list from the JSON Map
      List<dynamic> advancedList = jsonMap['advanced'];

      // Create a list of Advanced Sensors
      List<AdvancedSensor> advancedSensors = advancedList.map((sensorJson) {
        return AdvancedSensor(
          date: sensorJson['date'],
          endpoints: sensorJson['endpoints'],
          ip: sensorJson['ip'],
          name: sensorJson['name'],
        );
      }).toList();

      // Retrieve the "static" list from the JSON Map
      List<dynamic> staticList = jsonMap['static'];

      // Create a list of Static Sensors
      List<Sensor> staticSensors = staticList.map((sensorJson) {
        return Sensor(
          address: sensorJson['address'],
          date: sensorJson['date'],
          id: sensorJson['id'],
          type: sensorJson['type'],
          value: sensorJson['value'],
        );
      }).toList();

      // creating the list of lists
      List<List> sensorList = [staticSensors, advancedSensors];

      // adding the list to the database
      await box.put('cards', sensorList);

      // return the data
      return sensorList;
    } else {
      // if the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load last sensor data');
    }
  } else {
    // check if the data is in the box
    if (box.containsKey('cards')) {
      // return the data
      List<List> sensorList = box.get('cards')!.cast();

      return sensorList;
    }
  }
  throw Exception('Failed to load last sensor data, no data in database');
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

Future<List<Sensor>> getReportData(String startDate, String endDate) async {
  print("Start date: $startDate, end date: $endDate");
  final url = Uri.parse('https://andr3w.ddns.net/report');

  final jsonBody = jsonEncode({
    'start_date': startDate,
    'end_date': endDate,
  });

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonBody,
  );

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

void makeGetRequest(String ip, String endpoint) async {
  // Create the URL with parameters
  String url =
      'https://andr3w.ddns.net/advanced/request?ip=$ip&endpoint=$endpoint';

  // Make the GET request
  final response = await http.get(Uri.parse(url));

  // Handle the response
  if (response.statusCode == 200) {
    // Successful GET request
    // ignore: avoid_print
    print('GET request successful');
    // ignore: avoid_print
    print('Response body: ${response.body}');
  } else {
    // Error in GET request
    // ignore: avoid_print
    print('Error: GET request failed with status code ${response.statusCode}');
  }
}
