import 'package:flutter_test/flutter_test.dart';
import 'package:project_volt/app/session_controller.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

final testUser = UserFirebaseModel(
  uid: 'u1',
  namaLengkap: 'Aaliyah',
  email: 'a@x.id',
  role: 'mahasiswa',
);

void main() {
  test('signIn stores the user and notifies listeners', () {
    final session = SessionController();
    var notified = 0;
    session.addListener(() => notified++);

    session.signIn(testUser);

    expect(session.isSignedIn, isTrue);
    expect(session.user, testUser);
    expect(notified, 1);
  });

  test('signOut clears the user', () {
    final session = SessionController()..signIn(testUser);

    session.signOut();

    expect(session.isSignedIn, isFalse);
    expect(session.user, isNull);
  });
}
