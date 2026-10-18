part of 'movie_detail_bloc.dart';

enum MovieDetailStatus { loading, success, failure }

final class MovieDetailState extends Equatable {
  const MovieDetailState({
    this.status = MovieDetailStatus.loading,
    this.cast = const [],
    this.planets = const [],
    this.starships = const [],
    this.vehicles = const [],
    this.species = const [],
  });

  final MovieDetailStatus status;
  final List<String> cast;
  final List<String> planets;
  final List<String> starships;
  final List<String> vehicles;
  final List<String> species;

  @override
  List<Object?> get props => [status, cast, planets, starships, vehicles, species];
}
