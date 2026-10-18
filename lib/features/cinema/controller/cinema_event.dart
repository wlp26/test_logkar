part of 'cinema_bloc.dart';

sealed class CinemaEvent {
  const CinemaEvent();
}

final class CinemaStarted extends CinemaEvent {
  const CinemaStarted();
}

final class CinemaSelected extends CinemaEvent {
  const CinemaSelected(this.cinemaId);

  final String cinemaId;
}
