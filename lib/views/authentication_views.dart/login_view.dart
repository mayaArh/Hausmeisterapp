import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_exceptions.dart';
import 'package:mein_digitaler_hausmeister/services/auth/firebase_auth_provider.dart';
import '../../services/firestore_crud/firestore_data_service.dart';
import '../../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
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
              hintText: 'Email',
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
                await FirebaseAuthProvider().logIn(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuthProvider().currentUser;
                if (user?.isEmailVerified ?? false) {
                  FirestoreDataService().changeDocIdtoUID(user!);
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
                await DialogDisplay.showErrorDialog(
                    context, 'Der angegebene Benutzer existiert nicht');
              } on WrongPasswordAuthException {
                await DialogDisplay.showErrorDialog(
                    context, 'Falsches Passwort');
              } on NoInternetAuthException {
                await DialogDisplay.showErrorDialog(
                    context, 'Bitte verbinden Sie sich mit dem Internet.');
              } on GenericAuthException {
                await DialogDisplay.showErrorDialog(context,
                    'Bei der Anmeldung ist ein unbekannter Fehler aufgetreten. Bitte versuchen Sie es später erneut.');
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
