import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
final monthFormat = DateFormat.yMMMM('es_MX');
final monthShortFormat = DateFormat.yMMM('es_MX');
final monthAbbrFormat = DateFormat.MMM('es_MX');
final dateFormat = DateFormat('d MMM yyyy', 'es_MX');
