import 'package:flutter/foundation.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

/// Holds the signed-in user for the whole app.
class SessionController extends ChangeNotifier {
  UserFirebaseModel? _user;

  UserFirebaseModel? get user => _user;

  bool get isSignedIn => _user != null;

  void signIn(UserFirebaseModel user) {
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}
