import 'package:equatable/equatable.dart';

import '../../../../core/utils.dart';

class CinemaModel extends Equatable {
  const CinemaModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  LatLng get position => LatLng(latitude, longitude);

  @override
  List<Object?> get props => [id, name, address, latitude, longitude];
}

class RouteModel extends Equatable {
  const RouteModel({required this.distance, required this.duration});

  final double distance;
  final int duration;

  @override
  List<Object?> get props => [distance, duration];
}
