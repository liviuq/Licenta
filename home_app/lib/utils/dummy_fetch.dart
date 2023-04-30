import 'dart:convert';

import 'package:flutter/material.dart';

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

Future<List> getSensorTypes() async {
  final response = await http.get(Uri.parse('https://andr3w.ddns.net/types'));

  if (response.statusCode == 200) {
    // parsing the data
    var typesJson = jsonDecode(response.body)['types'];

    // creating the list
    List<String> types =
        typesJson != null ? List.from(typesJson) : List.empty();

    print(types);
    // return the list
    return types;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load sensor data');
  }
}
