import 'package:intl/intl.dart';

final DateFormat dateFormatter = DateFormat.yMd();

final NumberFormat numberFormatter = NumberFormat('#,##0.00');

String capitalize(String text) => text.split(' ').map((String word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '').join(' ');
