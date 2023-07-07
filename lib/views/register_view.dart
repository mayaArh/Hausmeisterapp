import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/registration_service.dart';

import '../services/auth/auth_exceptions.dart';
import '../services/auth/firebase_auth_provider.dart';
import '../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final RegistrationService _registrationService;

  @override
  void initState() {
    _password = TextEditingController();
    _email = TextEditingController();
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
          title: const Text('Registrieren'),
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
                hintText: 'App-Passwort festlegen',
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  //check if firestore user exists
                  if (await _registrationService.isAllowedUser(email)) {
                    await FirebaseAuthProvider().createUser(
                      email: email,
                      password: password,
                    );
                    await FirebaseAuthProvider().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  } else {
                    ErrorDialog.showErrorDialog(context,
                        'Leider sind Sie nicht in unserem System registriert. Bitte überprüfen Sie noch einmal Ihre E-Mail Adresse.');
                  }
                } on WeakPasswordAuthException {
                  await ErrorDialog.showErrorDialog(
                      context, 'Password zu schwach');
                } on EmailAlreadyInUseAuthException {
                  await ErrorDialog.showErrorDialog(context,
                      'Es existiert bereits ein verifizierter Nutzer mit dieser E-Mail Adresse.');
                } on InvalidEmailAuthException {
                  await ErrorDialog.showErrorDialog(
                      context, 'Keine valide E-Mail Adresse.');
                } on GenericAuthException {
                  await ErrorDialog.showErrorDialog(
                      context, 'Es gab einen Fehler bei der Registrierung.');
                }
              },
              child: const Text('Registrierung'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text(
                    "Bereits registriert? Hier geht's zur Anmeldung!"))
          ],
        ));
  }
}
