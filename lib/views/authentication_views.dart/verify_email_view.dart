import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';

import '../../services/auth/firebase_auth_provider.dart';

/// This class is responsible for asking the user to verify his email address.
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({
    super.key,
  });

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Mail Verifizierung'),
      ),
      body: Column(
        children: [
          const Text(
              "Um Ihre Identität zu bestätigen, haben wir eine E-Mail an die angegebene E-Mail Adresse versendet. Bitte schauen Sie in ihr E-Mail Postfach und verifizieren Sie ihre E-Mail Adresse."),
          TextButton(
              onPressed: () async {
                await FirebaseAuthProvider().sendEmailVerification();
              },
              child: const Text('E-Mail erneut senden.')),
          TextButton(
              onPressed: () async {
                await FirebaseAuthProvider().logOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text(
                  "E-Mail verifiziert? Hier geht's weiter zur Anmeldung!"))
        ],
      ),
    );
  }
}
