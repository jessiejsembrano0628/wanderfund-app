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
          final createdAt = authProvider.user?.createdAt;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Account details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
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
                  if (createdAt != null)
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Member since'),
                      subtitle: Text(
                        '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
