import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_event_bus.dart';
import '../../../core/utils.dart';
import '../data/data_sources/cinema_repository.dart';
import '../data/model/cinema_model.dart';

part 'cinema_event.dart';
part 'cinema_state.dart';

class CinemaBloc extends Bloc<CinemaEvent, CinemaState> {
  CinemaBloc(this._repository) : super(const CinemaState()) {
    on<CinemaStarted>(_onStarted);
    on<CinemaSelected>((event, emit) => emit(state.copyWith(selectedId: event.cinemaId)));
    _subscription = eventBus.on<ShowCinemaEvent>().listen((event) {
      if (event.cinemaId != null) add(CinemaSelected(event.cinemaId!));
    });
  }

  final CinemaRepository _repository;
  late final StreamSubscription<ShowCinemaEvent> _subscription;

  Future<void> _onStarted(CinemaStarted event, Emitter<CinemaState> emit) async {
    final current = await _repository.getCurrentLocation();
    final isDefault =
        current == null ||
        distanceBetween(current, CinemaRepository.defaultLocation) > 100000;
    final position = isDefault ? CinemaRepository.defaultLocation : current;
    final cinemas = [...CinemaRepository.cinemas]
      ..sort(
        (a, b) => distanceBetween(
          position,
          a.position,
        ).compareTo(distanceBetween(position, b.position)),
      );

    emit(
      state.copyWith(
        isLoading: false,
        position: position,
        isDefaultLocation: isDefault,
        cinemas: cinemas,
        selectedId: state.selectedId ?? cinemas.first.id,
      ),
    );

    await Future.wait(
      cinemas.map((cinema) async {
        final route = await _repository.getRoute(position, cinema.position);
        emit(state.copyWith(routes: {...state.routes, cinema.id: route}));
      }),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
