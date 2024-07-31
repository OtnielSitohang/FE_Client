import 'package:intl/intl.dart';

class DateUtils {
  static DateFormat _dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");

  static DateTime? parseDateString(String dateString) {
    try {
      DateTime parsedDate = _dateFormat.parseUtc(dateString);
      if (!isDateValid(parsedDate)) {
        throw Exception('Invalid date format');
      }
      return parsedDate;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  static bool isDateValid(DateTime date) {
    try {
      int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      return date.day <= daysInMonth;
    } catch (e) {
      return false;
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateFormat.format(dateTime.toUtc());
  }

  static String formattedDate(DateTime dateTime) {
    return '${_getDayName(dateTime.weekday)}, ${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
  }

  static String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }
}
