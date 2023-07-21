import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/colors.dart';
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
          Container(
              padding: const EdgeInsets.all(12.0),
              child: const Column(children: [
                Text(
                  "Um Ihre Identität zu bestätigen, haben wir eine E-Mail an die angegebene Mail-Adresse versendet.",
                  style: TextStyle(fontSize: 17),
                ),
                SizedBox(height: 10),
                Text(
                  'Bitte schauen Sie in Ihr Postfach und verifizieren Sie Ihre E-Mail Adresse.',
                  style: TextStyle(fontSize: 17),
                )
              ])),
          TextButton(
              onPressed: () async {
                await FirebaseAuthProvider().sendEmailVerification();
              },
              child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('E-Mail erneut senden.',
                      style: TextStyle(fontSize: 15)))),
          OutlinedButton(
              style: ButtonStyle(
                  side: MaterialStateProperty.all<BorderSide>(
                    const BorderSide(width: 2.0, color: middleBlueGrey),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(veryLightBlack)),
              onPressed: () async {
                await FirebaseAuthProvider().logOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Padding(
                  padding: EdgeInsets.all(11),
                  child: Text(
                    "E-Mail verifiziert? \nHier geht's weiter zur Anmeldung!",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  )))
        ],
      ),
    );
  }
}
