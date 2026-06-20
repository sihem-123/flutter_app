import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import 'event_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _showEvents = true;
  bool _showVenues = true;

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte d\'Alger'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'events') _showEvents = !_showEvents;
                if (value == 'venues') _showVenues = !_showVenues;
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'events',
                checked: _showEvents,
                child: const Text('Événements'),
              ),
              CheckedPopupMenuItem(
                value: 'venues',
                checked: _showVenues,
                child: const Text('Lieux'),
              ),
            ],
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(36.7538, 3.0588),
          initialZoom: 12,
          maxZoom: 18,
          minZoom: 8,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.algerculture.events',
          ),
          if (_showEvents)
            MarkerLayer(
              markers: dataService.upcomingEvents.map((event) {
                return Marker(
                  point: LatLng(event.latitude, event.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: event),
                      ),
                    ),
                    child: Tooltip(
                      message: event.title,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.event,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (_showVenues)
            MarkerLayer(
              markers: dataService.venues.map((venue) {
                return Marker(
                  point: LatLng(venue.latitude, venue.longitude),
                  width: 40,
                  height: 40,
                  child: Tooltip(
                    message: venue.name,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.move(
          const LatLng(36.7538, 3.0588),
          12,
        ),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
