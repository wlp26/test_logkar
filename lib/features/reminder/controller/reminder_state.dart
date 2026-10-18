part of 'reminder_bloc.dart';

final class ReminderState extends Equatable {
  const ReminderState({this.reminders = const []});

  final List<ReminderModel> reminders;

  @override
  List<Object?> get props => [reminders];
}
