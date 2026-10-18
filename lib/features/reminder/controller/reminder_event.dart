part of 'reminder_bloc.dart';

sealed class ReminderEvent {
  const ReminderEvent();
}

final class ReminderStarted extends ReminderEvent {
  const ReminderStarted();
}

final class ReminderAdded extends ReminderEvent {
  const ReminderAdded(this.reminder);

  final ReminderModel reminder;
}

final class ReminderDeleted extends ReminderEvent {
  const ReminderDeleted(this.id);

  final int id;
}
