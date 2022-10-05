import 'package:docs_clone_flutter/repository/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepoProvider = Provider(
  (ref) => AuthRepo(
    googleSignIn: GoogleSignIn(),
  ),
);

class AuthRepo {
  final GoogleSignIn _googleSignIn;

  AuthRepo({
    required GoogleSignIn googleSignIn,
  }) : _googleSignIn = googleSignIn;

  void signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        
      }
    } catch (e) {
      print(e);
    }
  }
}
