import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final String dateString;
  final DateFormat _dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
  final DateFormat _dateFormatToShow = DateFormat('HH:mm:ss');

  DateWidget({super.key, required this.dateString});

  @override
  Widget build(BuildContext context) {
    DateTime date = _dateFormat.parse(dateString);
    bool isToday = DateTime.now().day == date.day;

    if (isToday) {
      // if the date is today, display the time
      return Text(
        'Today @ ${_dateFormatToShow.format(date)}',
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      // if the date is not today, display the full date
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
      return Text(
        'On $formattedDate',
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
