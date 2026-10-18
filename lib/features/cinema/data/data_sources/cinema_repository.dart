import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils.dart';
import '../model/cinema_model.dart';

class CinemaRepository {
  CinemaRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const defaultLocation = LatLng(-6.175392, 106.827153);

  static const cinemas = [
    CinemaModel(
      id: 'plaza-senayan',
      name: 'Plaza Senayan XXI',
      address: 'Jl. Asia Afrika No.8, Senayan, Jakarta Pusat',
      latitude: -6.225500,
      longitude: 106.799700,
    ),
    CinemaModel(
      id: 'kota-kasablanka',
      name: 'Kota Kasablanka XXI',
      address: 'Jl. Casablanca Raya Kav.88, Tebet, Jakarta Selatan',
      latitude: -6.224300,
      longitude: 106.842700,
    ),
    CinemaModel(
      id: 'pondok-indah',
      name: 'Pondok Indah Mall XXI',
      address: 'Jl. Metro Pondok Indah, Kebayoran Lama, Jakarta Selatan',
      latitude: -6.265800,
      longitude: 106.783900,
    ),
    CinemaModel(
      id: 'gandaria-city',
      name: 'Gandaria City XXI',
      address: 'Jl. Sultan Iskandar Muda, Kebayoran Lama, Jakarta Selatan',
      latitude: -6.244100,
      longitude: 106.783500,
    ),
    CinemaModel(
      id: 'taman-anggrek',
      name: 'Taman Anggrek XXI',
      address: 'Jl. Letjen S. Parman Kav.21, Grogol, Jakarta Barat',
      latitude: -6.178600,
      longitude: 106.792000,
    ),
    CinemaModel(
      id: 'kelapa-gading',
      name: 'Mall Kelapa Gading XXI',
      address: 'Jl. Boulevard Kelapa Gading, Jakarta Utara',
      latitude: -6.157500,
      longitude: 106.908100,
    ),
  ];

  Future<LatLng?> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<RouteModel> getRoute(LatLng from, LatLng to) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}',
        queryParameters: {'overview': 'false'},
      );
      final route = (response.data!['routes'] as List).first as Map<String, dynamic>;
      return RouteModel(
        distance: (route['distance'] as num).toDouble(),
        duration: (route['duration'] as num).round(),
      );
    } catch (_) {
      final distance = distanceBetween(from, to);
      return RouteModel(
        distance: distance,
        duration: (distance / 1000 / 30 * 3600).round(),
      );
    }
  }
}
