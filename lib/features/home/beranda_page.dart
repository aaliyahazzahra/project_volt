import 'package:flutter/material.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

/// Placeholder Beranda. Phase 3 replaces the body with deadlines and classes.
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key, required this.user});

  final UserFirebaseModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${user.namaLengkap}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Beranda segera hadir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
