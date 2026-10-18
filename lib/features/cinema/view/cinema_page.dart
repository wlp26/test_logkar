import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils.dart';
import '../controller/cinema_bloc.dart';
import '../data/model/cinema_model.dart';

class CinemaPage extends StatelessWidget {
  const CinemaPage({super.key});

  Future<void> _navigate(CinemaState state, CinemaModel cinema) async {
    final destination = '${cinema.latitude},${cinema.longitude}';
    final origin = state.isDefaultLocation
        ? '&origin=${state.position.latitude},${state.position.longitude}'
        : '';
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destination$origin&travelmode=driving&dir_action=navigate',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cinemas')),
      body: BlocBuilder<CinemaBloc, CinemaState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Google Map',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.cinemas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cinema = state.cinemas[index];
                    final route = state.routes[cinema.id];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: cinema.id == state.selectedId
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => context.read<CinemaBloc>().add(
                          CinemaSelected(cinema.id),
                        ),
                        title: Text(
                          cinema.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          route == null
                              ? 'Calculating ETA...'
                              : 'ETA ${formatDuration(route.duration)} • ${formatDistance(route.distance)}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Navigate',
                          icon: const Icon(Icons.navigation),
                          onPressed: () => _navigate(state, cinema),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
