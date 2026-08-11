import 'package:intl/intl.dart';

class DateFormatter{
  DateFormatter._();
  static String fullIndo(DateTime date){
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }
}