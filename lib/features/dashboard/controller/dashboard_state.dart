part of 'dashboard_bloc.dart';

enum DashboardStatus { loading, success, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.movies = const [],
  });

  final DashboardStatus status;
  final List<MovieModel> movies;

  @override
  List<Object?> get props => [status, movies];
}
