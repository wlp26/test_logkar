import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_event_bus.dart';
import '../../../core/utils.dart';
import '../../cinema/data/data_sources/cinema_repository.dart';
import '../../cinema/data/model/cinema_model.dart';
import '../../dashboard/data/model/movie_model.dart';
import '../controller/reminder_bloc.dart';
import '../data/model/reminder_model.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state.reminders.isEmpty) {
            return const Center(
              child: Text(
                'No reminders yet.\nOpen a movie and tap "Set Reminder".',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.reminders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final reminder = state.reminders[index];
              final isPast = reminder.showTime.isBefore(DateTime.now());
              return Card(
                child: ListTile(
                  leading: Icon(
                    isPast ? Icons.alarm_off : Icons.alarm,
                    color: isPast ? Colors.grey : null,
                  ),
                  title: Text(
                    reminder.movieTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${reminder.cinemaName}\n${formatDateTime(reminder.showTime)}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Directions',
                        icon: const Icon(Icons.directions),
                        onPressed: () => eventBus.fire(ShowCinemaEvent(reminder.cinemaId)),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            context.read<ReminderBloc>().add(ReminderDeleted(reminder.id)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> showReminderSheet(BuildContext context, MovieModel movie) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReminderForm(movie: movie),
  );
}

class _ReminderForm extends StatefulWidget {
  const _ReminderForm({required this.movie});

  final MovieModel movie;

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  static const _options = {
    0: 'At showtime',
    15: '15 minutes before',
    30: '30 minutes before',
    60: '1 hour before',
  };

  CinemaModel _cinema = CinemaRepository.cinemas.first;
  DateTime _showTime = DateTime.now().add(const Duration(hours: 2));
  int _minutesBefore = 30;
  String? _error;

  Future<void> _pickShowTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _showTime,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_showTime),
    );
    if (time == null) return;
    setState(() {
      _showTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      movieTitle: widget.movie.title,
      cinemaId: _cinema.id,
      cinemaName: _cinema.name,
      showTime: _showTime,
      minutesBefore: _minutesBefore,
    );
    if (!reminder.remindAt.isAfter(DateTime.now())) {
      setState(() => _error = 'Reminder time has already passed.');
      return;
    }
    context.read<ReminderBloc>().add(ReminderAdded(reminder));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set Reminder',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              widget.movie.title,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<CinemaModel>(
              initialValue: _cinema,
              decoration: const InputDecoration(labelText: 'Cinema'),
              items: [
                for (final cinema in CinemaRepository.cinemas)
                  DropdownMenuItem(value: cinema, child: Text(cinema.name)),
              ],
              onChanged: (cinema) => setState(() => _cinema = cinema!),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Showtime'),
              subtitle: Text(formatDateTime(_showTime)),
              trailing: const Icon(Icons.edit),
              onTap: _pickShowTime,
            ),
            DropdownButtonFormField<int>(
              initialValue: _minutesBefore,
              decoration: const InputDecoration(labelText: 'Remind me'),
              items: [
                for (final option in _options.entries)
                  DropdownMenuItem(value: option.key, child: Text(option.value)),
              ],
              onChanged: (value) => setState(() => _minutesBefore = value!),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text('Save Reminder')),
          ],
        ),
      ),
    );
  }
}
