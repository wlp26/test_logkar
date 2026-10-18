import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  const ReminderModel({
    required this.id,
    required this.movieTitle,
    required this.cinemaId,
    required this.cinemaName,
    required this.showTime,
    required this.minutesBefore,
  });

  final int id;
  final String movieTitle;
  final String cinemaId;
  final String cinemaName;
  final DateTime showTime;
  final int minutesBefore;

  DateTime get remindAt => showTime.subtract(Duration(minutes: minutesBefore));

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as int,
      movieTitle: json['movie_title'] as String,
      cinemaId: json['cinema_id'] as String,
      cinemaName: json['cinema_name'] as String,
      showTime: DateTime.parse(json['show_time'] as String),
      minutesBefore: json['minutes_before'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_title': movieTitle,
      'cinema_id': cinemaId,
      'cinema_name': cinemaName,
      'show_time': showTime.toIso8601String(),
      'minutes_before': minutesBefore,
    };
  }

  @override
  List<Object?> get props => [id, movieTitle, cinemaId, cinemaName, showTime, minutesBefore];
}
