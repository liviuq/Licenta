import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/sensor.dart';
import '../utils/fetch.dart';
import '../widgets/sensor_category.dart';

class ReportRoute extends StatefulWidget {
  const ReportRoute({super.key});

  @override
  State<ReportRoute> createState() => _ReportRouteState();
}

class _ReportRouteState extends State<ReportRoute> {
  DateFormat dateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");

  String startDate = '';
  String endDate = '';

  List<Sensor> sensorList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          transform: GradientRotation(-5 / 10),
          begin: Alignment.topCenter,
          end: Alignment(0.8, 1),
          colors: [
            Color(0xff0f082c),
            Colors.blue,
          ],
          tileMode: TileMode.mirror,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text('Generate report'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
              ),
              const Center(
                child: SensorCategory(
                  title: 'Start date',
                  textColor: Colors.black,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
                  initialValue: DateTime.now().toString(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  icon: const Icon(Icons.event),
                  dateLabelText: 'Date',
                  timeLabelText: "Hour",
                  onChanged: (val) {
                    DateTime date = DateFormat('yyyy-MM-dd HH:mm').parse(val);
                    // subtract 3 hours to get GMT time
                    date = date.subtract(const Duration(hours: 3));
                    String formattedDate = dateFormat.format(date);
                    startDate = formattedDate;
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
              ),
              const Center(
                child: SensorCategory(
                  title: 'End date',
                  textColor: Colors.black,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
                  initialValue: DateTime.now().toString(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  icon: const Icon(Icons.event),
                  dateLabelText: 'Date',
                  timeLabelText: "Hour",
                  onChanged: (val) {
                    DateTime date = DateFormat('yyyy-MM-dd HH:mm').parse(val);
                    // subtract 3 hours to get GMT time
                    date = date.subtract(const Duration(hours: 3));
                    String formattedDate = dateFormat.format(date);
                    endDate = formattedDate;
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
              ),
              FloatingActionButton.extended(
                key: UniqueKey(),
                heroTag: UniqueKey(),
                label: Text(
                  'Generate report',
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
                onPressed: () async {
                  if (startDate.isEmpty || endDate.isEmpty) {
                    return;
                  }
                  sensorList = await getReportData(startDate, endDate);

                  final pdf = pw.Document();

                  pdf.addPage(
                    pw.Page(
                      build: (pw.Context context) => pw.Center(
                        child: pw.Text('Hello World!'),
                      ),
                    ),
                  );

                  var file = File('');
                  final fileName = 'report.pdf';

                  var status = await Permission.storage.status;
                  if (status != PermissionStatus.granted) {
                    status = await Permission.storage.request();
                  }
                  if (status.isGranted) {
                    const downloadsFolderPath = '/storage/emulated/0/Download/';
                    Directory dir = Directory(downloadsFolderPath);
                    file = File('${dir.path}/$fileName');
                    print('file does ${file.existsSync()}');
                  }

                  final byteData = await pdf.save();
                  print(byteData);
                  try {
                    await file.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                  } on FileSystemException catch (err) {
                    print("error");
                    // handle error
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
