import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  final bool initialSearch;
  final EventCategory? filterCategory;

  const EventsScreen({
    super.key,
    this.initialSearch = false,
    this.filterCategory,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  EventCategory? _selectedCategory;
  bool _showFreeOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.filterCategory;
  }

  List<Event> _filterEvents(List<Event> events) {
    var filtered = events;

    if (_searchQuery.isNotEmpty) {
      filtered = events
          .where((e) =>
              e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.location.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != null) {
      filtered =
          filtered.where((e) => e.category == _selectedCategory).toList();
    }

    if (_showFreeOnly) {
      filtered = filtered.where((e) => e.isFree).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final filteredEvents = _filterEvents(dataService.events);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        actions: [
          IconButton(
            icon: Icon(
              _showFreeOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFreeOnly ? AppTheme.goldColor : Colors.white,
            ),
            onPressed: () => setState(() => _showFreeOnly = !_showFreeOnly),
            tooltip: 'Gratuits uniquement',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: widget.initialSearch,
              decoration: InputDecoration(
                hintText: 'Rechercher un événement...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // Category filter
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip('Tous', null),
                ...EventCategory.values.map(
                  (cat) => _buildFilterChip(_categoryName(cat), cat),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filteredEvents.length} événement${filteredEvents.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Events list
          Expanded(
            child: filteredEvents.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun événement trouvé',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return EventCard(
                        event: event,
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
      ),
    );
  }

  Widget _buildFilterChip(String label, EventCategory? category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _categoryName(EventCategory cat) {
    switch (cat) {
      case EventCategory.concert:
        return 'Concert';
      case EventCategory.theatre:
        return 'Théâtre';
      case EventCategory.festival:
        return 'Festival';
      case EventCategory.expo:
        return 'Exposition';
      case EventCategory.cinema:
        return 'Cinéma';
      case EventCategory.danse:
        return 'Danse';
      default:
        return 'Autre';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
