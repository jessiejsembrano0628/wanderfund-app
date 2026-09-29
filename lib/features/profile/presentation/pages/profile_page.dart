import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final userDetails = authProvider.userDetails;
          final displayName = userDetails != null
              ? '${userDetails.firstName} ${userDetails.lastName}'
              : authProvider.user?.name ?? 'Unknown User';
          final email =
              userDetails?.email ?? authProvider.user?.email ?? 'Not available';
          final phone = userDetails?.mobileNumber ?? 'Not available';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Phone: $phone',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Account details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Full name'),
                  subtitle: Text(displayName),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Mobile number'),
                  subtitle: Text(phone),
                ),
                if (authProvider.user != null)
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Member since'),
                    subtitle: Text(
                      '${authProvider.user!.createdAt.year}-${authProvider.user!.createdAt.month.toString().padLeft(2, '0')}-${authProvider.user!.createdAt.day.toString().padLeft(2, '0')}',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
