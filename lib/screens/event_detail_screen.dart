import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/smart_image.dart';
import 'booking_screen.dart';
import 'login_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final currentEvent = dataService.events.firstWhere(
      (e) => e.id == event.id,
      orElse: () => event,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SmartImage(
                    imageUrl: currentEvent.imageUrl,
                    localAsset: currentEvent.localImage.isNotEmpty
                        ? currentEvent.localImage
                        : currentEvent.categoryAsset,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  currentEvent.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: currentEvent.isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () =>
                    context.read<DataService>().toggleFavorite(event.id),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentEvent.categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: currentEvent.isFree
                                ? Colors.green
                                : AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentEvent.isFree
                                ? 'Gratuit'
                                : '${currentEvent.price.toInt()} DA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      currentEvent.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Info cards
                    _InfoRow(
                      icon: Icons.calendar_today,
                      color: AppTheme.primaryColor,
                      label: 'Date',
                      value: DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                          .format(currentEvent.date),
                    ),
                    if (currentEvent.time.isNotEmpty)
                      _InfoRow(
                        icon: Icons.access_time,
                        color: AppTheme.primaryColor,
                        label: 'Heure',
                        value: currentEvent.time,
                      ),
                    _InfoRow(
                      icon: Icons.location_on,
                      color: AppTheme.accentColor,
                      label: 'Lieu',
                      value: currentEvent.venue.isNotEmpty
                          ? currentEvent.venue
                          : currentEvent.location,
                    ),
                    _InfoRow(
                      icon: Icons.location_city,
                      color: Colors.blue,
                      label: 'Adresse',
                      value: currentEvent.location,
                    ),
                    _InfoRow(
                      icon: Icons.people,
                      color: Colors.orange,
                      label: 'Places disponibles',
                      value:
                          '${currentEvent.availableSeats} / ${currentEvent.capacity}',
                    ),
                    if (currentEvent.organizer.isNotEmpty)
                      _InfoRow(
                        icon: Icons.business,
                        color: Colors.purple,
                        label: 'Organisateur',
                        value: currentEvent.organizer,
                      ),
                    if (currentEvent.contactPhone.isNotEmpty)
                      _InfoRow(
                        icon: Icons.phone,
                        color: Colors.green,
                        label: 'Contact',
                        value: currentEvent.contactPhone,
                      ),
                    const Divider(height: 32),
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentEvent.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    // Tags
                    if (currentEvent.tags.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: currentEvent.tags
                            .map((tag) => Chip(
                                  label: Text(
                                    '#$tag',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor:
                                      AppTheme.primaryColor.withValues(alpha: 0.1),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: currentEvent.isAvailable
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    final auth = context.read<AuthService>();
                    if (!auth.isLoggedIn) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ));
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(event: currentEvent),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    currentEvent.isFree
                        ? 'Réserver (Gratuit)'
                        : 'Réserver - ${currentEvent.price.toInt()} DA',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  'Complet - Plus de places disponibles',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
