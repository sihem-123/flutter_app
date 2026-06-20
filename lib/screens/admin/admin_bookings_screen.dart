import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/data_service.dart';
import '../../theme/app_theme.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Réservations')),
      body: dataService.bookings.isEmpty
          ? const Center(child: Text('Aucune réservation'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dataService.bookings.length,
              itemBuilder: (context, index) {
                final booking = dataService.bookings[index];
                return _BookingAdminCard(booking: booking);
              },
            ),
    );
  }
}

class _BookingAdminCard extends StatelessWidget {
  final Booking booking;

  const _BookingAdminCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          booking.eventTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          booking.userName,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(booking.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            booking.statusLabel,
            style: TextStyle(
              color: _statusColor(booking.status),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row('Email', booking.userEmail),
                _Row('Téléphone', booking.userPhone),
                _Row('Billets', '${booking.numberOfTickets}'),
                _Row('Prix total',
                    '${booking.totalPrice.toInt()} DA'),
                _Row('Paiement', booking.paymentMethodLabel),
                _Row(
                  'Date de réservation',
                  DateFormat('d MMM yyyy HH:mm', 'fr_FR')
                      .format(booking.bookingDate),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: BookingStatus.values.map((status) {
                    return ElevatedButton(
                      onPressed: booking.status != status
                          ? () => context.read<DataService>()
                              .updateBookingStatus(booking.id, status)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _statusColor(status),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                      ),
                      child: Text(
                        _statusLabel(status),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _Row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(color: AppTheme.textSecondary))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.completed:
        return 'Terminée';
      default:
        return 'En attente';
    }
  }
}
