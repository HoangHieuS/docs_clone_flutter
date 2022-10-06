import 'dart:convert';

import 'package:docs_clone_flutter/constants.dart';
import 'package:docs_clone_flutter/repository/repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../models/models.dart';

final authRepoProvider = Provider(
  (ref) => AuthRepo(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepo: LocalStorageRepo(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepo {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepo _localStorageRepo;

  AuthRepo({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepo localStorageRepo,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepo = localStorageRepo;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(
      error: 'Some unexoected error occurred.',
      data: null,
    );
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
          email: user.email,
          name: user.displayName ?? '',
          profilePic: user.photoUrl ?? '',
          uid: '',
          token: '',
        );

        var res = await _client.post(Uri.parse('$host/api/signup'),
            body: userAcc.toJson(),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            });

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            error = ErrorModel(
              error: null,
              data: newUser,
            );
            _localStorageRepo.setToken(newUser.token);
            break;
        }
      }
    } on PlatformException catch (e) {
      error = ErrorModel(
        error: e.message,
        data: null,
      );}
     catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(
      error: 'Some unexoected error occurred.',
      data: null,
    );
    try {
      String? token = await _localStorageRepo.getToken();

      if (token != null) {
        var res = await _client.get(Uri.parse('$host/'), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        });

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              jsonEncode(jsonDecode(res.body)['user']),
            ).copyWith(token: token);
            error = ErrorModel(
              error: null,
              data: newUser,
            );
            _localStorageRepo.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }
}
