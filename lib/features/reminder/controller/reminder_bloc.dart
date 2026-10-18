import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_event_bus.dart';
import '../../../core/utils.dart';
import '../data/data_sources/reminder_repository.dart';
import '../data/model/reminder_model.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderBloc(this._repository) : super(const ReminderState()) {
    on<ReminderStarted>(
      (event, emit) => emit(ReminderState(reminders: _repository.getReminders())),
    );
    on<ReminderAdded>(_onAdded);
    on<ReminderDeleted>(_onDeleted);
  }

  final ReminderRepository _repository;

  Future<void> _onAdded(ReminderAdded event, Emitter<ReminderState> emit) async {
    try {
      await _repository.addReminder(event.reminder);
      emit(ReminderState(reminders: _repository.getReminders()));
      eventBus.fire(
        MessageEvent('Reminder set for ${formatDateTime(event.reminder.remindAt)}'),
      );
    } catch (_) {
      eventBus.fire(const MessageEvent('Failed to set reminder'));
    }
  }

  Future<void> _onDeleted(ReminderDeleted event, Emitter<ReminderState> emit) async {
    await _repository.deleteReminder(event.id);
    emit(ReminderState(reminders: _repository.getReminders()));
  }
}
