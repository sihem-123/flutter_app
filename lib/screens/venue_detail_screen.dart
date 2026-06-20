import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/venue_model.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/smart_image.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class VenueDetailScreen extends StatelessWidget {
  final Venue venue;

  const VenueDetailScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final venueEvents = dataService.events.where((e) => e.venueId == venue.id).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                venue.name,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: SmartImage(
                imageUrl: venue.imageUrl,
                localAsset: venue.localImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            venue.address,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Capacité: ${venue.capacity} personnes',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    if (venue.phone.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(venue.phone),
                        ],
                      ),
                    ],
                    if (venue.email.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.email, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(venue.email),
                        ],
                      ),
                    ],
                    if (venue.description.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text(
                        'À propos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        venue.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                    if (venue.facilities.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text(
                        'Équipements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: venue.facilities
                            .map((f) => Chip(
                                  label: Text(f, style: const TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      AppTheme.primaryColor.withValues(alpha: 0.1),
                                ))
                            .toList(),
                      ),
                    ],
                    if (venueEvents.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text(
                        'Événements à venir ici',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...venueEvents.map((event) => EventCard(
                            event: event,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(event: event),
                              ),
                            ),
                          )),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
