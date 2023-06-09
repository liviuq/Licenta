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
          title: const Text('Reports'),
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
// Create a list to store table rows
                  List<List<String>> tableData = [];

                  // Add header row
                  tableData
                      .add(['Count', 'Address', 'Date', 'ID', 'Type', 'Value']);

                  // Add data rows
                  for (int i = 0; i < sensorList.length; i++) {
                    Sensor sensor = sensorList[i];
                    tableData.add([
                      (i + 1).toString(), // Count starts from 1
                      sensor.address,
                      sensor.date,
                      sensor.id.toString(),
                      sensor.type,
                      sensor.value.toString(),
                    ]);
                  }

                  pdf.addPage(
                    pw.MultiPage(
                      header: (pw.Context context) {
                        // Get the current date and format it
                        final currentDate = DateTime.now();
                        final formattedDate =
                            DateFormat('EEE, dd MMM yyyy').format(currentDate);

                        return pw.Container(
                          alignment: pw.Alignment.centerRight,
                          margin: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Text(
                            'Data recorded between \n $startDate and $endDate. \nReport has been generated on: $formattedDate',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      footer: (pw.Context context) {
                        return pw.Container(
                          alignment: pw.Alignment.centerRight,
                          margin: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Text(
                            'Licensed to: FII. Report generated by: \nSmart Home App 2023',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      build: (pw.Context context) {
                        return <pw.Widget>[
                          pw.Table.fromTextArray(
                            context: context,
                            data: tableData,
                          ),
                        ];
                      },
                    ),
                  );

                  final byteData = await pdf.save();
                  try {
                    // it does work with 'report.pdf' but not with the name
                    //await writeFile(byteData,"${DateTime.now().toString().replaceAll(' ', '_')}.pdf");
                    await writeFile(byteData, 'report.pdf');
                  } on FileSystemException catch (err) {
                    print("error: $err");
                  }

                  final snackBar = SnackBar(
                    content: const Text('File saved to Downloads folder.'),
                    action: SnackBarAction(
                      label: 'Close',
                      onPressed: () {},
                    ),
                  );

                  // display the snackbar
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<File> writeFile(Uint8List data, String name) async {
    // ask for storage permission if not already given
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    String tempPath = "/storage/emulated/0/Download";
    var filePath = tempPath + '/$name';

    // the data
    var bytes = ByteData.view(data.buffer);
    final buffer = bytes.buffer;
    // save the data in the path
    return File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
