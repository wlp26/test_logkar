import 'package:event_bus/event_bus.dart';

final eventBus = EventBus();

class ShowCinemaEvent {
  const ShowCinemaEvent([this.cinemaId]);

  final String? cinemaId;
}

class MessageEvent {
  const MessageEvent(this.message);

  final String message;
}
