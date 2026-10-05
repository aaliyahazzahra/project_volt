import 'package:flutter_test/flutter_test.dart';
import 'package:project_volt/app/app_router.dart';
import 'package:project_volt/app/session_controller.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

final testUser = UserFirebaseModel(
  uid: 'u1',
  namaLengkap: 'Aaliyah',
  email: 'a@x.id',
  role: 'mahasiswa',
);

void main() {
  test('signed-out user going to /kelas is sent to /login', () {
    final session = SessionController();
    expect(appRedirect('/kelas', session), '/login');
  });

  test('signed-out user on /splash stays on /splash', () {
    final session = SessionController();
    expect(appRedirect('/splash', session), isNull);
  });

  test('signed-in user on /login is sent to /beranda', () {
    final session = SessionController()..signIn(testUser);
    expect(appRedirect('/login', session), '/beranda');
  });

  test('signed-in user on /kelas stays put', () {
    final session = SessionController()..signIn(testUser);
    expect(appRedirect('/kelas', session), isNull);
  });
}
