import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/data_service.dart';
import '../../widgets/smart_image.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();

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
      body: dataService.events.isEmpty
          ? const Center(child: Text('Aucun événement'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataService.events.length,
              itemBuilder: (context, index) {
                final event = dataService.events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SmartImage(
                        imageUrl: event.imageUrl,
                        localAsset: event.localImage.isNotEmpty
                            ? event.localImage
                            : event.categoryAsset,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${DateFormat('d MMM yyyy', 'fr_FR').format(event.date)} | ${event.isFree ? "Gratuit" : "${event.price.toInt()} DA"}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEventForm(context, event: event),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(context, event),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
    DateTime selectedDate = event?.date ?? DateTime.now().add(const Duration(days: 7));
    EventCategory selectedCategory = event?.category ?? EventCategory.concert;
    bool isFree = event?.isFree ?? true;
    bool isFeatured = event?.isFeatured ?? false;
    int capacity = event?.capacity ?? 100;

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
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event == null ? 'Ajouter un événement' : 'Modifier l\'événement',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titre'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: venueController,
                      decoration: const InputDecoration(labelText: 'Nom du lieu'),
                    ),
                    const SizedBox(height: 12),
                    // Date picker
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                          DateFormat('EEE d MMM yyyy', 'fr_FR').format(selectedDate)),
                      subtitle: const Text('Date de l\'événement'),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setModalState(() => selectedDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Category
                    DropdownButtonFormField<EventCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Catégorie'),
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
                        decoration: const InputDecoration(labelText: 'Prix (DA)'),
                        keyboardType: TextInputType.number,
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                            localImage: selectedCategory.name == 'concert'
                                ? 'assets/images/concert.png'
                                : selectedCategory.name == 'theatre'
                                    ? 'assets/images/theatre.png'
                                    : selectedCategory.name == 'festival'
                                        ? 'assets/images/festival.png'
                                        : selectedCategory.name == 'expo'
                                            ? 'assets/images/expo.png'
                                            : selectedCategory.name == 'cinema'
                                                ? 'assets/images/cinema.png'
                                                : selectedCategory.name == 'danse'
                                                    ? 'assets/images/danse.png'
                                                    : 'assets/images/placeholder.png',
                            capacity: capacity,
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
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer "${event.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<DataService>().deleteEvent(event.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
