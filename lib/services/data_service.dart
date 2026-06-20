import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../models/venue_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Event> _events = [];
  List<Venue> _venues = [];
  List<Booking> _bookings = [];
  List<UserModel> _users = [];

  List<Event> get events => _events;
  List<Venue> get venues => _venues;
  List<Booking> get bookings => _bookings;
  List<UserModel> get users => _users;

  List<Event> get featuredEvents => _events.where((e) => e.isFeatured).toList();
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> initialize() async {
    await _loadFromStorage();
    if (_events.isEmpty) {
      await _loadSampleData();
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final eventsJson = prefs.getString('events');
      if (eventsJson != null) {
        final List<dynamic> decoded = jsonDecode(eventsJson);
        _events = decoded.map((e) => Event.fromJson(e)).toList();
      }

      final venuesJson = prefs.getString('venues');
      if (venuesJson != null) {
        final List<dynamic> decoded = jsonDecode(venuesJson);
        _venues = decoded.map((v) => Venue.fromJson(v)).toList();
      }

      final bookingsJson = prefs.getString('bookings');
      if (bookingsJson != null) {
        final List<dynamic> decoded = jsonDecode(bookingsJson);
        _bookings = decoded.map((b) => Booking.fromJson(b)).toList();
      }

      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List<dynamic> decoded = jsonDecode(usersJson);
        _users = decoded.map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading from storage: $e');
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('events', jsonEncode(_events.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveVenues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('venues', jsonEncode(_venues.map((v) => v.toJson()).toList()));
  }

  Future<void> _saveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookings', jsonEncode(_bookings.map((b) => b.toJson()).toList()));
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', jsonEncode(_users.map((u) => u.toJson()).toList()));
  }

  // ===== EVENTS =====
  Future<void> addEvent(Event event) async {
    _events.add(event);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> toggleFavorite(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index].isFavorite = !_events[index].isFavorite;
      await _saveEvents();
      notifyListeners();
    }
  }

  List<Event> getEventsByCategory(EventCategory category) {
    return _events.where((e) => e.category == category).toList();
  }

  List<Event> searchEvents(String query) {
    final q = query.toLowerCase();
    return _events.where((e) =>
      e.title.toLowerCase().contains(q) ||
      e.description.toLowerCase().contains(q) ||
      e.location.toLowerCase().contains(q) ||
      e.venue.toLowerCase().contains(q)
    ).toList();
  }

  // ===== VENUES =====
  Future<void> addVenue(Venue venue) async {
    _venues.add(venue);
    await _saveVenues();
    notifyListeners();
  }

  Future<void> updateVenue(Venue venue) async {
    final index = _venues.indexWhere((v) => v.id == venue.id);
    if (index != -1) {
      _venues[index] = venue;
      await _saveVenues();
      notifyListeners();
    }
  }

  Future<void> deleteVenue(String id) async {
    _venues.removeWhere((v) => v.id == id);
    await _saveVenues();
    notifyListeners();
  }

  // ===== BOOKINGS =====
  Future<void> addBooking(Booking booking) async {
    _bookings.add(booking);
    // Update event booked count
    final eventIndex = _events.indexWhere((e) => e.id == booking.eventId);
    if (eventIndex != -1) {
      final event = _events[eventIndex];
      _events[eventIndex] = event.copyWith(
        bookedCount: event.bookedCount + booking.numberOfTickets,
      );
      await _saveEvents();
    }
    await _saveBookings();
    notifyListeners();
  }

  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index].status = status;
      await _saveBookings();
      notifyListeners();
    }
  }

  List<Booking> getUserBookings(String userId) {
    return _bookings.where((b) => b.userId == userId).toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  // ===== USERS =====
  Future<void> addUser(UserModel user) async {
    _users.add(user);
    await _saveUsers();
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      await _saveUsers();
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((u) => u.id == id);
    await _saveUsers();
    notifyListeners();
  }

  // ===== SAMPLE DATA =====
  Future<void> _loadSampleData() async {
    // Venues
    _venues = [
      Venue(
        id: 'v1',
        name: 'Théâtre National Algérien Mahieddine Bachtarzi',
        description: 'Le plus grand théâtre d\'Alger, au cœur de la ville.',
        address: '7 Rue Hassiba Ben Bouali, Alger Centre',
        city: 'Alger',
        latitude: 36.7369,
        longitude: 3.0855,
        localImage: 'assets/images/venue1.png',
        capacity: 1200,
        phone: '+213 21 63 01 44',
        email: 'contact@tna.dz',
        website: 'https://tna.dz',
        facilities: ['Scène principale', 'Salle de répétition', 'Parking', 'Cafétéria'],
      ),
      Venue(
        id: 'v2',
        name: 'Salle Ibn Zeydoun',
        description: 'Salle de spectacle moderne au Palais de la Culture.',
        address: 'Palais de la Culture, Bir Mourad Raïs, Alger',
        city: 'Alger',
        latitude: 36.7308,
        longitude: 3.0481,
        localImage: 'assets/images/venue2.png',
        capacity: 800,
        phone: '+213 21 73 00 00',
        email: 'contact@artsetculturealger.dz',
        website: 'https://artsetculturealger.dz',
        facilities: ['Grande scène', 'Foyer', 'Parking', 'Restaurant'],
      ),
      Venue(
        id: 'v3',
        name: 'Salle Ahmed Bey',
        description: 'Salle polyvalente pour concerts et événements culturels.',
        address: 'Rue Didouche Mourad, Alger',
        city: 'Alger',
        latitude: 36.7600,
        longitude: 3.0514,
        localImage: 'assets/images/venue3.png',
        capacity: 600,
        phone: '+213 21 73 00 01',
        facilities: ['Scène', 'Loges', 'Bar'],
      ),
      Venue(
        id: 'v4',
        name: 'Cinémathèque Algérienne',
        description: 'Le temple du 7ème art en Algérie.',
        address: 'Rue Ben M\'Hidi Larbi, Alger',
        city: 'Alger',
        latitude: 36.7523,
        longitude: 3.0594,
        localImage: 'assets/images/venue4.png',
        capacity: 300,
        phone: '+213 21 63 81 20',
        facilities: ['Salle de projection', 'Bibliothèque', 'Café'],
      ),
      Venue(
        id: 'v5',
        name: 'Palais de la Culture Moufdi Zakaria',
        description: 'Centre culturel principal d\'Alger pour les arts et expositions.',
        address: 'Plateau des Annassers, Alger',
        city: 'Alger',
        latitude: 36.7316,
        longitude: 3.0480,
        localImage: 'assets/images/venue5.png',
        capacity: 2000,
        phone: '+213 21 73 01 02',
        email: 'paiement@artsetculturealger.dz',
        website: 'https://artsetculturealger.dz',
        facilities: ['Grande salle', 'Galeries', 'Salle de conférences', 'Parking', 'Restaurant'],
      ),
    ];

    // Events
    _events = [
      Event(
        id: 'e1',
        title: 'Festival International de Jazz d\'Alger',
        description: 'Le plus grand festival de jazz du Maghreb revient pour sa 15ème édition. Des artistes internationaux et locaux se produiront durant 3 jours mémorables.',
        localImage: 'assets/images/event_photo1.jpg',
        date: DateTime.now().add(const Duration(days: 15)),
        time: '20:00',
        location: 'Alger Centre',
        venue: 'Théâtre National Algérien',
        venueId: 'v1',
        latitude: 36.7369,
        longitude: 3.0855,
        category: EventCategory.concert,
        price: 1500,
        isFree: false,
        isFeatured: true,
        capacity: 1200,
        bookedCount: 450,
        organizer: 'Arts et Culture Alger',
        contactEmail: 'contact@artsetculturealger.dz',
        contactPhone: '+213 21 71 57 57',
        tags: ['jazz', 'musique', 'festival', 'international'],
      ),
      Event(
        id: 'e2',
        title: 'Nuit du Théâtre Algérien',
        description: 'Une soirée exceptionnelle célébrant le théâtre algérien avec des pièces jouées par les meilleures troupes du pays.',
        localImage: 'assets/images/event_photo2.jpg',
        date: DateTime.now().add(const Duration(days: 7)),
        time: '19:30',
        location: 'Bir Mourad Raïs, Alger',
        venue: 'Salle Ibn Zeydoun',
        venueId: 'v2',
        latitude: 36.7308,
        longitude: 3.0481,
        category: EventCategory.theatre,
        price: 800,
        isFree: false,
        isFeatured: true,
        capacity: 800,
        bookedCount: 320,
        organizer: 'Palais de la Culture',
        contactEmail: 'contact@artsetculturealger.dz',
        contactPhone: '+213 21 73 00 00',
        tags: ['théâtre', 'art', 'algérien'],
      ),
      Event(
        id: 'e3',
        title: 'Festival de l\'Art Pictural d\'Alger',
        description: 'Exposition des œuvres de peintres algériens contemporains et classiques. Un voyage à travers l\'art pictural algérien.',
        localImage: 'assets/images/event_photo3.jpg',
        date: DateTime.now().add(const Duration(days: 3)),
        time: '10:00',
        location: 'Plateau des Annassers, Alger',
        venue: 'Palais de la Culture',
        venueId: 'v5',
        latitude: 36.7316,
        longitude: 3.0480,
        category: EventCategory.expo,
        price: 0,
        isFree: true,
        isFeatured: true,
        capacity: 500,
        bookedCount: 180,
        organizer: 'Ministère de la Culture',
        contactEmail: 'contact@artsetculturealger.dz',
        contactPhone: '+213 21 73 01 02',
        tags: ['art', 'peinture', 'exposition', 'gratuit'],
      ),
      Event(
        id: 'e4',
        title: 'Concert de Musique Andalouse',
        description: 'Soirée de musique classique andalouse avec l\'Orchestre National Algérien. Un patrimoine vivant en concert.',
        localImage: 'assets/images/event_photo4.jpg',
        date: DateTime.now().add(const Duration(days: 20)),
        time: '21:00',
        location: 'Alger',
        venue: 'Salle Ahmed Bey',
        venueId: 'v3',
        latitude: 36.7600,
        longitude: 3.0514,
        category: EventCategory.concert,
        price: 1000,
        isFree: false,
        isFeatured: false,
        capacity: 600,
        bookedCount: 200,
        organizer: 'Arts et Culture Alger',
        tags: ['musique', 'andalouse', 'classique', 'patrimoine'],
      ),
      Event(
        id: 'e5',
        title: 'Festival du Film Méditerranéen',
        description: 'Sélection de films de la région méditerranéenne. Projections, débats et rencontres avec des cinéastes.',
        localImage: 'assets/images/event_photo5.jpg',
        date: DateTime.now().add(const Duration(days: 25)),
        time: '18:00',
        location: 'Alger Centre',
        venue: 'Cinémathèque Algérienne',
        venueId: 'v4',
        latitude: 36.7523,
        longitude: 3.0594,
        category: EventCategory.cinema,
        price: 500,
        isFree: false,
        isFeatured: false,
        capacity: 300,
        bookedCount: 120,
        organizer: 'Cinémathèque Algérienne',
        tags: ['cinéma', 'film', 'méditerranée', 'festival'],
      ),
      Event(
        id: 'e6',
        title: 'Spectacle de Danse Contemporaine',
        description: 'Performance de danse contemporaine mêlant tradition algérienne et modernité. Une chorégraphie unique par la Compagnie Lazurite.',
        localImage: 'assets/images/event_photo6.jpg',
        date: DateTime.now().add(const Duration(days: 10)),
        time: '20:30',
        location: 'Alger',
        venue: 'Salle Ibn Zeydoun',
        venueId: 'v2',
        latitude: 36.7308,
        longitude: 3.0481,
        category: EventCategory.danse,
        price: 1200,
        isFree: false,
        isFeatured: true,
        capacity: 800,
        bookedCount: 350,
        organizer: 'Compagnie Lazurite',
        tags: ['danse', 'contemporain', 'performance'],
      ),
      Event(
        id: 'e7',
        title: 'Festival Culturel du Ramadan',
        description: 'Festivités culturelles spéciales pendant le Ramadan : musique, théâtre, poésie et gastronomie.',
        localImage: 'assets/images/event_photo7.jpg',
        date: DateTime.now().add(const Duration(days: 30)),
        time: '21:30',
        location: 'Alger',
        venue: 'Palais de la Culture',
        venueId: 'v5',
        latitude: 36.7316,
        longitude: 3.0480,
        category: EventCategory.festival,
        price: 0,
        isFree: true,
        isFeatured: false,
        capacity: 2000,
        bookedCount: 500,
        organizer: 'Wilaya d\'Alger',
        tags: ['ramadan', 'festival', 'culture', 'gratuit'],
      ),
    ];

    // Sample users
    _users = [
      UserModel(
        id: 'u1',
        name: 'Ahmed Benali',
        email: 'ahmed.benali@gmail.com',
        phone: '+213 660 123 456',
        role: UserRole.user,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'u2',
        name: 'Fatima Zohra',
        email: 'fatima.zohra@gmail.com',
        phone: '+213 770 234 567',
        role: UserRole.user,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: 'u3',
        name: 'Karim Djamal',
        email: 'karim.djamal@gmail.com',
        phone: '+213 550 345 678',
        role: UserRole.user,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    await _saveEvents();
    await _saveVenues();
    await _saveUsers();
    notifyListeners();
  }

  // Reset all data
  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('events');
    await prefs.remove('venues');
    await prefs.remove('bookings');
    await prefs.remove('users');
    _events = [];
    _venues = [];
    _bookings = [];
    _users = [];
    await _loadSampleData();
  }
}
