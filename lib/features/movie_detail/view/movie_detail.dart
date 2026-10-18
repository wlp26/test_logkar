import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_event_bus.dart';
import '../../../core/utils.dart';
import '../../../core/widgets.dart';
import '../../dashboard/data/data_sources/movie_repository.dart';
import '../../dashboard/data/model/movie_model.dart';
import '../../reminder/view/reminder_page.dart';
import '../controller/movie_detail_bloc.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  static Route<void> route(MovieModel movie) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) =>
            MovieDetailBloc(movie, context.read<MovieRepository>())
              ..add(const MovieDetailStarted()),
        child: const MovieDetailPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = context.read<MovieDetailBloc>().movie;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            flexibleSpace: FlexibleSpaceBar(background: ImagePlaceholder()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList.list(
              children: [
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Episode ${movie.episodeId} • ${movie.releaseDate?.year ?? '-'}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => showReminderSheet(context, movie),
                        icon: const Icon(Icons.alarm_add),
                        label: const Text('Set Reminder'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => eventBus.fire(const ShowCinemaEvent()),
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text('Find Cinema'),
                      ),
                    ),
                  ],
                ),
                _Section(
                  title: 'Summary',
                  child: Text(cleanCrawl(movie.openingCrawl)),
                ),
                _Section(
                  title: 'Info',
                  child: Column(
                    children: [
                      _InfoRow('Director', movie.director),
                      _InfoRow('Producer', movie.producer),
                      _InfoRow('Episode', '${movie.episodeId}'),
                      _InfoRow('Release date', formatDate(movie.releaseDate)),
                    ],
                  ),
                ),
                BlocBuilder<MovieDetailBloc, MovieDetailState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case MovieDetailStatus.loading:
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      case MovieDetailStatus.failure:
                        return ErrorView(
                          message: 'Failed to load cast',
                          onRetry: () => context.read<MovieDetailBloc>().add(
                            const MovieDetailStarted(),
                          ),
                        );
                      case MovieDetailStatus.success:
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _NamesSection(title: 'Cast', names: state.cast),
                            _NamesSection(
                              title: 'Planets',
                              names: state.planets,
                            ),
                            _NamesSection(
                              title: 'Starships',
                              names: state.starships,
                            ),
                            _NamesSection(
                              title: 'Vehicles',
                              names: state.vehicles,
                            ),
                            _NamesSection(
                              title: 'Species',
                              names: state.species,
                            ),
                          ],
                        );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _NamesSection extends StatelessWidget {
  const _NamesSection({required this.title, required this.names});

  final String title;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();
    return _Section(
      title: '$title (${names.length})',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final name in names) Chip(label: Text(name))],
      ),
    );
  }
}
