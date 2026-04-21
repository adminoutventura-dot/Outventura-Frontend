import 'package:intl/intl.dart';

class FormateadorFecha {
  FormateadorFecha._();

  static final DateFormat _short = DateFormat("d MMM yyyy", 'es');
  static final DateFormat _long = DateFormat("d 'de' MMMM 'de' yyyy", 'es');
  static final DateFormat _withTime = DateFormat("d MMM yyyy HH:mm", 'es');

  static String short(DateTime date) => _short.format(date);
  static String long(DateTime date) => _long.format(date);
  static String withTime(DateTime date) => _withTime.format(date);
}
