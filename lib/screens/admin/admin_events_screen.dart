import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/smart_image.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final filtered = dataService.events.where((e) =>
        e.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Événements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showEventForm(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un événement...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Aucun événement'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final event = filtered[index];
                      return _buildEventCard(event, dataService);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, DataService dataService) {
    final availablePhotos = _getAvailablePhotos();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEventForm(context, event: event),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: SmartImage(
                    imageUrl: event.imageUrl,
                    localAsset: event.localImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM yyyy', 'fr_FR').format(event.date),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.category, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          event.categoryName,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${event.bookedCount}/${event.capacity}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.isFeatured
                          ? AppTheme.goldColor.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.isFeatured ? 'À la une' : 'Normal',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: event.isFeatured ? AppTheme.goldColor : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showImagePicker(context, event, availablePhotos),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, color: Colors.blue, size: 18),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _deleteEvent(context, event),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete, color: Colors.red, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getAvailablePhotos() {
    return List.generate(187, (i) => 'assets/images/photo_583008082099824${5550 + i}_y.jpg')
        .where((path) {
      try {
        return true;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  void _showImagePicker(BuildContext context, Event event, List<String> photos) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choisir une image'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  final updated = event.copyWith(localImage: photos[index]);
                  await context.read<DataService>().updateEvent(updated);
                  if (context.mounted) Navigator.pop(ctx);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEventForm(BuildContext context, {Event? event}) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descController = TextEditingController(text: event?.description ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    final venueController = TextEditingController(text: event?.venue ?? '');
    final priceController = TextEditingController(
        text: event?.price.toString() ?? '0');
    final capacityController = TextEditingController(
        text: event?.capacity.toString() ?? '100');
    DateTime selectedDate = event?.date ?? DateTime.now().add(const Duration(days: 7));
    EventCategory selectedCategory = event?.category ?? EventCategory.concert;
    bool isFree = event?.isFree ?? true;
    bool isFeatured = event?.isFeatured ?? false;
    String selectedImage = event?.localImage ?? 'assets/images/placeholder.png';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event == null ? 'Ajouter un événement' : "Modifier l'événement",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: venueController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du lieu',
                        prefixIcon: Icon(Icons.place),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: capacityController,
                      decoration: const InputDecoration(
                        labelText: 'Capacité',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                          DateFormat('EEE d MMM yyyy', 'fr_FR').format(selectedDate)),
                      subtitle: const Text("Date de l'événement"),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setModalState(() => selectedDate = date);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EventCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: EventCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (v) => setModalState(() => selectedCategory = v!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Gratuit'),
                            value: isFree,
                            onChanged: (v) => setModalState(() => isFree = v),
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('À la une'),
                            value: isFeatured,
                            onChanged: (v) => setModalState(() => isFeatured = v),
                          ),
                        ),
                      ],
                    ),
                    if (!isFree)
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Prix (DA)',
                          prefixIcon: Icon(Icons.monetization_on),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: Image.asset(
                          selectedImage,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Aucune image',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          final dataService = context.read<DataService>();
                          final newEvent = Event(
                            id: event?.id ??
                                'ev_${DateTime.now().millisecondsSinceEpoch}',
                            title: titleController.text,
                            description: descController.text,
                            date: selectedDate,
                            location: locationController.text,
                            venue: venueController.text,
                            category: selectedCategory,
                            price: double.tryParse(priceController.text) ?? 0,
                            isFree: isFree,
                            isFeatured: isFeatured,
                            localImage: selectedImage,
                            capacity: int.tryParse(capacityController.text) ?? 100,
                          );
                          if (event == null) {
                            await dataService.addEvent(newEvent);
                          } else {
                            await dataService.updateEvent(newEvent);
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Text(event == null ? 'Ajouter' : 'Enregistrer'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  void _deleteEvent(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer'),
        content: Text('Voulez-vous supprimer "${event.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<DataService>().deleteEvent(event.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}