import 'dart:convert';

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
