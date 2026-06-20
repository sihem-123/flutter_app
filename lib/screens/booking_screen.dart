import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Event event;

  const BookingScreen({super.key, required this.event});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _tickets = 1;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  double get _totalPrice => widget.event.price * _tickets;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Réservation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('EEE d MMM yyyy', 'fr_FR')
                                .format(widget.event.date),
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on,
                              size: 14, color: AppTheme.accentColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.event.venue,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Vos informations',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // User info (read-only)
              _InfoTile(label: 'Nom', value: user.name),
              _InfoTile(label: 'Email', value: user.email),
              if (user.phone.isNotEmpty)
                _InfoTile(label: 'Téléphone', value: user.phone),
              const SizedBox(height: 20),
              // Number of tickets
              const Text(
                'Nombre de billets',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _tickets > 1
                        ? () => setState(() => _tickets--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppTheme.primaryColor,
                    iconSize: 32,
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      '$_tickets',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: _tickets < widget.event.availableSeats
                        ? () => setState(() => _tickets++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppTheme.primaryColor,
                    iconSize: 32,
                  ),
                  const Spacer(),
                  Text(
                    widget.event.isFree
                        ? 'Gratuit'
                        : 'Total: ${_totalPrice.toInt()} DA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.event.isFree
                          ? Colors.green
                          : AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
              if (!widget.event.isFree) ...[
                const SizedBox(height: 20),
                const Text(
                  'Mode de paiement',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...PaymentMethod.values.map((method) {
                  return RadioListTile<PaymentMethod>(
                    value: method,
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                    title: Text(_paymentLabel(method)),
                    secondary: Icon(_paymentIcon(method)),
                  );
                }),
                if (_paymentMethod == PaymentMethod.virement) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations de virement',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Email: paiement@artsetculturealger.dz'),
                        Text('Objet: Réservation Event\'s AL'),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Informations supplémentaires...',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Confirmer la réservation',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _paymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.virement:
        return 'Virement bancaire';
      case PaymentMethod.card:
        return 'Carte bancaire';
      default:
        return 'Espèces (sur place)';
    }
  }

  IconData _paymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.virement:
        return Icons.account_balance;
      case PaymentMethod.card:
        return Icons.credit_card;
      default:
        return Icons.money;
    }
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    
    final auth = context.read<AuthService>();
    final dataService = context.read<DataService>();
    final user = auth.currentUser!;

    final booking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userPhone: user.phone,
      eventDate: widget.event.date,
      numberOfTickets: _tickets,
      totalPrice: _totalPrice,
      status: BookingStatus.confirmed,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await dataService.addBooking(booking);
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(booking: booking),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
