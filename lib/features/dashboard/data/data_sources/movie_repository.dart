import 'package:dio/dio.dart';

import '../model/movie_model.dart';

class MovieRepository {
  MovieRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://swapi.dev/api',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;
  final Map<String, String> _names = {};

  Future<List<MovieModel>> getMovies() async {
    final movies = <MovieModel>[];
    String? nextUrl = '/films/';

    try {
      while (nextUrl != null) {
        final response = await _dio.get<Map<String, dynamic>>(nextUrl);
        final page = MovieListResponse.fromJson(response.data ?? {});
        movies.addAll(page.results);
        nextUrl = page.next;
      }
    } on DioException catch (e) {
      throw MovieException(e.toString());
    }

    movies.sort((a, b) => a.episodeId.compareTo(b.episodeId));
    return movies;
  }

  Future<MovieModel> getMovieById(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/films/$id/');
      return MovieModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw MovieException(e.toString());
    }
  }

  Future<List<String>> getNames(List<String> urls) async {
    try {
      return await Future.wait(
        urls.map((url) async {
          if (_names.containsKey(url)) return _names[url]!;
          final response = await _dio.get<Map<String, dynamic>>(url);
          return _names[url] = response.data?['name'] as String? ?? '-';
        }),
      );
    } on DioException catch (e) {
      throw MovieException(e.toString());
    }
  }
}

class MovieException implements Exception {
  const MovieException(this.message);

  final String message;

  @override
  String toString() => message;
}
