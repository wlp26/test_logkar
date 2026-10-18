import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class LatLng extends Equatable {
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

String formatDate(DateTime? date) {
  return date == null ? '-' : DateFormat('d MMM yyyy').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('EEE, d MMM yyyy • HH:mm').format(date);
}

String formatDuration(int seconds) {
  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return '$minutes min';
  return '${minutes ~/ 60} h ${minutes % 60} min';
}

String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

String cleanCrawl(String crawl) {
  return crawl
      .replaceAll('\r\n', '\n')
      .split('\n\n')
      .map((paragraph) => paragraph.replaceAll('\n', ' ').trim())
      .where((paragraph) => paragraph.isNotEmpty)
      .join('\n\n');
}

double distanceBetween(LatLng from, LatLng to) {
  const earthRadius = 6371000.0;
  final dLat = _radians(to.latitude - from.latitude);
  final dLng = _radians(to.longitude - from.longitude);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_radians(from.latitude)) *
          cos(_radians(to.latitude)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _radians(double degree) => degree * pi / 180;
