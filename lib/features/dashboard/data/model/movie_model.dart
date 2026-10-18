class MovieModel {
  final String title;
  final int episodeId;
  final String openingCrawl;
  final String director;
  final String producer;
  final DateTime? releaseDate;

  final List<String> characters;
  final List<String> planets;
  final List<String> starships;
  final List<String> vehicles;
  final List<String> species;

  final DateTime? created;
  final DateTime? edited;
  final String url;

  const MovieModel({
    required this.title,
    required this.episodeId,
    required this.openingCrawl,
    required this.director,
    required this.producer,
    required this.releaseDate,
    required this.characters,
    required this.planets,
    required this.starships,
    required this.vehicles,
    required this.species,
    required this.created,
    required this.edited,
    required this.url,
  });

  int? get id {
    final segments = Uri.parse(url).pathSegments.where((s) => s.isNotEmpty);
    return segments.isEmpty ? null : int.tryParse(segments.last);
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      title: json['title'] as String? ?? '',
      episodeId: json['episode_id'] as int? ?? 0,
      openingCrawl: json['opening_crawl'] as String? ?? '',
      director: json['director'] as String? ?? '',
      producer: json['producer'] as String? ?? '',
      releaseDate: DateTime.tryParse(json['release_date'] as String? ?? ''),
      characters: _stringList(json['characters']),
      planets: _stringList(json['planets']),
      starships: _stringList(json['starships']),
      vehicles: _stringList(json['vehicles']),
      species: _stringList(json['species']),
      created: DateTime.tryParse(json['created'] as String? ?? ''),
      edited: DateTime.tryParse(json['edited'] as String? ?? ''),
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'episode_id': episodeId,
      'opening_crawl': openingCrawl,
      'director': director,
      'producer': producer,
      'release_date': releaseDate?.toIso8601String().substring(0, 10),
      'characters': characters,
      'planets': planets,
      'starships': starships,
      'vehicles': vehicles,
      'species': species,
      'created': created?.toIso8601String(),
      'edited': edited?.toIso8601String(),
      'url': url,
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }
}

class MovieListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<MovieModel> results;

  const MovieListResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory MovieListResponse.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    return MovieListResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results is List
          ? results
                .whereType<Map<String, dynamic>>()
                .map(MovieModel.fromJson)
                .toList()
          : const [],
    );
  }
}
