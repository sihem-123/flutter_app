import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'admin_events_screen.dart';
import 'admin_venues_screen.dart';
import 'admin_users_screen.dart';
import 'admin_bookings_screen.dart';
import '../login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final dataService = context.watch<DataService>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Administration'),
          ],
        ),
        actions: [
          if (auth.isSuperAdmin)
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _showAdminAccounts(context, auth),
              tooltip: 'Comptes admin',
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF283593)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        auth.currentUser?.roleLabel ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(
                  title: 'Événements',
                  value: '${dataService.events.length}',
                  icon: Icons.event,
                  color: AppTheme.primaryColor,
                ),
                _StatCard(
                  title: 'Lieux',
                  value: '${dataService.venues.length}',
                  icon: Icons.place,
                  color: AppTheme.accentColor,
                ),
                _StatCard(
                  title: 'Réservations',
                  value: '${dataService.bookings.length}',
                  icon: Icons.confirmation_number,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Utilisateurs',
                  value: '${dataService.users.length}',
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Gestion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _AdminMenuCard(
              icon: Icons.event,
              title: 'Gérer les Événements',
              subtitle: '${dataService.events.length} événements',
              color: AppTheme.primaryColor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminEventsScreen()),
              ),
            ),
            _AdminMenuCard(
              icon: Icons.place,
              title: 'Gérer les Lieux',
              subtitle: '${dataService.venues.length} lieux',
              color: AppTheme.accentColor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminVenuesScreen()),
              ),
            ),
            _AdminMenuCard(
              icon: Icons.confirmation_number,
              title: 'Gérer les Réservations',
              subtitle: '${dataService.bookings.length} réservations',
              color: Colors.orange,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminBookingsScreen()),
              ),
            ),
            _AdminMenuCard(
              icon: Icons.people,
              title: 'Gérer les Utilisateurs',
              subtitle: '${dataService.users.length} utilisateurs',
              color: Colors.green,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen()),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAdminAccounts(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comptes Administrateurs Event\'s AL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Identifiants des comptes administrateurs:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const _AdminAccountInfo(
              role: 'Super Admin',
              email: 'superadmin@eventalapp.dz',
              password: 'Super@2025',
            ),
            const Divider(),
            const _AdminAccountInfo(
              role: 'Admin 1',
              email: 'admin@eventalapp.dz',
              password: 'Admin@2025',
            ),
            const Divider(),
            const _AdminAccountInfo(
              role: 'Admin 2',
              email: 'admin@algerculture.dz',
              password: 'Admin@2025',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _AdminAccountInfo extends StatelessWidget {
  final String role;
  final String email;
  final String password;

  const _AdminAccountInfo({
    required this.role,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(role,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        Text('Email: $email'),
        Text('Mot de passe: $password'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
