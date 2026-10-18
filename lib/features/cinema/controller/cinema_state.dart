part of 'cinema_bloc.dart';

final class CinemaState extends Equatable {
  const CinemaState({
    this.isLoading = true,
    this.position = CinemaRepository.defaultLocation,
    this.isDefaultLocation = false,
    this.cinemas = const [],
    this.routes = const {},
    this.selectedId,
  });

  final bool isLoading;
  final LatLng position;
  final bool isDefaultLocation;
  final List<CinemaModel> cinemas;
  final Map<String, RouteModel> routes;
  final String? selectedId;

  CinemaModel? get selected {
    for (final cinema in cinemas) {
      if (cinema.id == selectedId) return cinema;
    }
    return null;
  }

  RouteModel? get selectedRoute => routes[selectedId];

  CinemaState copyWith({
    bool? isLoading,
    LatLng? position,
    bool? isDefaultLocation,
    List<CinemaModel>? cinemas,
    Map<String, RouteModel>? routes,
    String? selectedId,
  }) {
    return CinemaState(
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      isDefaultLocation: isDefaultLocation ?? this.isDefaultLocation,
      cinemas: cinemas ?? this.cinemas,
      routes: routes ?? this.routes,
      selectedId: selectedId ?? this.selectedId,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    position,
    isDefaultLocation,
    cinemas,
    routes,
    selectedId,
  ];
}
