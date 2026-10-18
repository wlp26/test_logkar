import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets.dart';
import '../../movie_detail/view/movie_detail.dart';
import '../controller/dashboard_bloc.dart';
import '../data/model/movie_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TES Logkar',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          switch (state.status) {
            case DashboardStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case DashboardStatus.failure:
              return ErrorView(
                message: 'Failed to load movies',
                onRetry: () =>
                    context.read<DashboardBloc>().add(const DashboardStarted()),
              );
            case DashboardStatus.success:
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<DashboardBloc>().add(const DashboardStarted()),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: state.movies.length,
                  itemBuilder: (context, index) =>
                      _MovieCard(movie: state.movies[index]),
                ),
              );
          }
        },
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});

  final MovieModel movie;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(MovieDetailPage.route(movie)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: ImagePlaceholder()),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'Episode ${movie.episodeId} • ${movie.releaseDate?.year ?? '-'}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
