import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dashboard/data/data_sources/movie_repository.dart';
import '../../dashboard/data/model/movie_model.dart';

part 'movie_detail_event.dart';
part 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  MovieDetailBloc(this.movie, this._repository) : super(const MovieDetailState()) {
    on<MovieDetailStarted>(_onStarted);
  }

  final MovieModel movie;
  final MovieRepository _repository;

  Future<void> _onStarted(
    MovieDetailStarted event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(const MovieDetailState());
    try {
      final results = await Future.wait([
        _repository.getNames(movie.characters),
        _repository.getNames(movie.planets),
        _repository.getNames(movie.starships),
        _repository.getNames(movie.vehicles),
        _repository.getNames(movie.species),
      ]);
      emit(
        MovieDetailState(
          status: MovieDetailStatus.success,
          cast: results[0],
          planets: results[1],
          starships: results[2],
          vehicles: results[3],
          species: results[4],
        ),
      );
    } on MovieException {
      emit(const MovieDetailState(status: MovieDetailStatus.failure));
    }
  }
}
