import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_exceptions.dart';
import '../../services/auth/auth_service.dart';
import '../../services/firestore_crud/registration_service.dart';
import '../../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final RegistrationService _registrationService;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _registrationService = RegistrationService();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anmelden'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Arbeits-Email-Adresse',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Passwort',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final userCredential = await AuthService.firebase().logIn(
                  email: email,
                  password: password,
                );
                developer.log(userCredential.toString());
                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  _registrationService.changeDocIdtoUID(user!);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    citiesOverviewRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
              } on UserNotFoundAuthException {
                await ErrorDialog.showErrorDialog(context, 'User not found');
              } on WrongPasswordAuthException {
                await ErrorDialog.showErrorDialog(context, 'Wrong password');
              } on GenericAuthException {
                await ErrorDialog.showErrorDialog(
                    context, 'Authentication Error');
              }
            },
            child: const Text('Anmelden.'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text(
                  "Noch nicht registriert? Hier geht's zur Registrierung!"))
        ],
      ),
    );
  }
}
