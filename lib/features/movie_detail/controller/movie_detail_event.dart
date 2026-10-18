part of 'movie_detail_bloc.dart';

sealed class MovieDetailEvent {
  const MovieDetailEvent();
}

final class MovieDetailStarted extends MovieDetailEvent {
  const MovieDetailStarted();
}
