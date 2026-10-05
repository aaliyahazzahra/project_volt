import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/home/beranda_page.dart';

final testUser = UserFirebaseModel(
  uid: 'u1',
  namaLengkap: 'Aaliyah',
  email: 'a@x.id',
  role: 'mahasiswa',
);

void main() {
  testWidgets('Beranda greets the user by name', (tester) async {
    await tester.pumpWidget(MaterialApp(home: BerandaPage(user: testUser)));

    expect(find.text('Halo, Aaliyah'), findsOneWidget);
  });
}
