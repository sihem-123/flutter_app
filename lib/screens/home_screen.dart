import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'events_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final dataService = context.watch<DataService>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, Color(0xFF283593)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjour, ${auth.currentUser?.name.split(' ').first ?? 'Visiteur'} 👋',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Découvrez les événements culturels',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_outlined,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EventsScreen(initialSearch: true),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          'Rechercher un événement...',
                          style: TextStyle(color: Colors.grey[500], fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Categories
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Catégories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: EventCategory.values.map((cat) {
                    return _CategoryChip(
                      category: cat,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EventsScreen(filterCategory: cat),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Featured Events
              if (dataService.featuredEvents.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'À la une',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const EventsScreen()),
                        ),
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: dataService.featuredEvents.length,
                    itemBuilder: (context, index) {
                      final event = dataService.featuredEvents[index];
                      return EventCard(
                        event: event,
                        compact: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: event),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              // Upcoming Events
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prochains événements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EventsScreen()),
                      ),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
              ),
              ...dataService.upcomingEvents.take(5).map((event) => EventCard(
                    event: event,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: event),
                      ),
                    ),
                  )),
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final EventCategory category;
  final VoidCallback onTap;

  const _CategoryChip({required this.category, required this.onTap});

  String get _label {
    switch (category) {
      case EventCategory.concert:
        return 'Concert';
      case EventCategory.theatre:
        return 'Théâtre';
      case EventCategory.festival:
        return 'Festival';
      case EventCategory.expo:
        return 'Expo';
      case EventCategory.cinema:
        return 'Cinéma';
      case EventCategory.danse:
        return 'Danse';
      default:
        return 'Autre';
    }
  }

  IconData get _icon {
    switch (category) {
      case EventCategory.concert:
        return Icons.music_note;
      case EventCategory.theatre:
        return Icons.theater_comedy;
      case EventCategory.festival:
        return Icons.festival;
      case EventCategory.expo:
        return Icons.palette;
      case EventCategory.cinema:
        return Icons.movie;
      case EventCategory.danse:
        return Icons.directions_run;
      default:
        return Icons.event;
    }
  }

  Color get _color {
    switch (category) {
      case EventCategory.concert:
        return Colors.purple;
      case EventCategory.theatre:
        return Colors.blue;
      case EventCategory.festival:
        return Colors.orange;
      case EventCategory.expo:
        return Colors.green;
      case EventCategory.cinema:
        return Colors.red;
      case EventCategory.danse:
        return Colors.pink;
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _color.withValues(alpha: 0.3)),
              ),
              child: Icon(_icon, color: _color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              _label,
              style: TextStyle(
                fontSize: 11,
                color: _color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
