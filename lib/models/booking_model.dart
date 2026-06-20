enum BookingStatus { pending, confirmed, cancelled, completed }

enum PaymentMethod { cash, virement, card }

class Booking {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final DateTime bookingDate;
  final DateTime eventDate;
  final int numberOfTickets;
  final double totalPrice;
  BookingStatus status;
  final PaymentMethod paymentMethod;
  final String? paymentReference;
  final String? notes;

  Booking({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone = '',
    DateTime? bookingDate,
    required this.eventDate,
    this.numberOfTickets = 1,
    this.totalPrice = 0,
    this.status = BookingStatus.pending,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentReference,
    this.notes,
  }) : bookingDate = bookingDate ?? DateTime.now();

  String get statusLabel {
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

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.virement:
        return 'Virement bancaire';
      case PaymentMethod.card:
        return 'Carte bancaire';
      default:
        return 'Espèces';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'bookingDate': bookingDate.toIso8601String(),
      'eventDate': eventDate.toIso8601String(),
      'numberOfTickets': numberOfTickets,
      'totalPrice': totalPrice,
      'status': status.index,
      'paymentMethod': paymentMethod.index,
      'paymentReference': paymentReference,
      'notes': notes,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'] ?? '',
      bookingDate: DateTime.tryParse(json['bookingDate'] ?? '') ?? DateTime.now(),
      eventDate: DateTime.tryParse(json['eventDate'] ?? '') ?? DateTime.now(),
      numberOfTickets: json['numberOfTickets'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: BookingStatus.values[json['status'] ?? 0],
      paymentMethod: PaymentMethod.values[json['paymentMethod'] ?? 0],
      paymentReference: json['paymentReference'],
      notes: json['notes'],
    );
  }
}
