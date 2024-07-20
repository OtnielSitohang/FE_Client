import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<void> updateUser(BuildContext context, User updatedUser) async {
    try {
      if (_user != null) {
        final responseData = await _authService
            .updateProfile(updatedUser.copyWith(id: _user!.id));
        if (responseData != null) {
          _user = User.fromJson(responseData);
          notifyListeners();
        } else {
          throw Exception(
              'Failed to update profile: response data is null or invalid');
        }
      } else {
        throw Exception('User is null');
      }
    } catch (e) {
      print('Failed to update user: $e');
      String errorMessage = 'Failed to update profile. Please try again later.';

      // Handle specific error cases
      if (e.toString().contains('Unauthorized')) {
        errorMessage = 'Failed to update profile. Unauthorized access.';
      } else if (e.toString().contains('Bad request')) {
        errorMessage = 'Failed to update profile. Invalid data provided.';
      } else if (e.toString().contains('Not found')) {
        errorMessage = 'Failed to update profile. Endpoint not found.';
      } else if (e.toString().contains('XMLHttpRequest error')) {
        errorMessage = 'Failed to update profile. Network error occurred.';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
