import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_event_bus.dart';
import '../data/data_sources/movie_repository.dart';
import '../data/model/movie_model.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
  }

  final MovieRepository _repository;

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.movies.isEmpty) {
      emit(const DashboardState(status: DashboardStatus.loading));
    }
    try {
      final movies = await _repository.getMovies();
      emit(DashboardState(status: DashboardStatus.success, movies: movies));
    } on MovieException {
      if (state.movies.isEmpty) {
        emit(const DashboardState(status: DashboardStatus.failure));
      } else {
        eventBus.fire(const MessageEvent('Failed to refresh movies'));
      }
    }
  }
}
