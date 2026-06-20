import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/venue_model.dart';
import '../../services/data_service.dart';
import '../../widgets/smart_image.dart';

class AdminVenuesScreen extends StatelessWidget {
  const AdminVenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Lieux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showVenueForm(context),
          ),
        ],
      ),
      body: dataService.venues.isEmpty
          ? const Center(child: Text('Aucun lieu'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataService.venues.length,
              itemBuilder: (context, index) {
                final venue = dataService.venues[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SmartImage(
                        imageUrl: venue.imageUrl,
                        localAsset: venue.localImage,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      venue.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('Capacité: ${venue.capacity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showVenueForm(context, venue: venue),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteVenue(context, venue),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showVenueForm(BuildContext context, {Venue? venue}) {
    final nameController = TextEditingController(text: venue?.name ?? '');
    final addressController = TextEditingController(text: venue?.address ?? '');
    final descController = TextEditingController(text: venue?.description ?? '');
    final phoneController = TextEditingController(text: venue?.phone ?? '');
    final capacityController = TextEditingController(
        text: venue?.capacity.toString() ?? '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                venue == null ? 'Ajouter un lieu' : 'Modifier le lieu',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom du lieu'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacité'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final dataService = context.read<DataService>();
                    final newVenue = Venue(
                      id: venue?.id ??
                          'vn_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text,
                      address: addressController.text,
                      description: descController.text,
                      phone: phoneController.text,
                      capacity: int.tryParse(capacityController.text) ?? 0,
                      localImage: 'assets/images/venue1.png',
                    );
                    if (venue == null) {
                      await dataService.addVenue(newVenue);
                    } else {
                      await dataService.updateVenue(newVenue);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(venue == null ? 'Ajouter' : 'Enregistrer'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteVenue(BuildContext context, Venue venue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer "${venue.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<DataService>().deleteVenue(venue.id);
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
