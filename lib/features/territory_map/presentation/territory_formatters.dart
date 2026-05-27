import 'package:intl/intl.dart';

abstract final class TerritoryFormatters {
  static String area(double squareMeters) {
    if (squareMeters >= 1000000) {
      return '${(squareMeters / 1000000).toStringAsFixed(2)} km²';
    }
    if (squareMeters >= 10000) {
      return '${(squareMeters / 10000).toStringAsFixed(2)} ha';
    }
    return '${squareMeters.round()} m²';
  }

  static String duration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = value.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  static String distance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.round()} m';
  }

  static String date(DateTime value) => DateFormat.yMMMd().format(value);
}
