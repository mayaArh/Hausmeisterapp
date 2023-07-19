import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/firebase_auth_provider.dart';
import '../../services/firestore_crud/firestore_data_service.dart';
import '../../utilities/show_dialog.dart';

/// This class is responsible for displaying the register screen
///  including possible error messages.
class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _password = TextEditingController();
    _email = TextEditingController();
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
        body: SingleChildScrollView(
            child: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  hintText: 'Arbeits-Mail-Adresse',
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.all(8)),
              style: const TextStyle(
                fontSize: 17,
                height: 2,
              ),
            ),
            TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    hintText: 'App-Passwort festlegen',
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.all(8)),
                style: const TextStyle(
                  fontSize: 17,
                  height: 2,
                )),
            const SizedBox(
              height: 22,
            ),
            OutlinedButton(
                style: ButtonStyle(
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(width: 2.0, color: Colors.blueGrey.shade500),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white12)),
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    //check if firestore user exists
                    if (await FirestoreDataService().isAllowedUser(email)) {
                      await FirebaseAuthProvider().createUser(
                        email: email,
                        password: password,
                      );
                      await FirebaseAuthProvider().sendEmailVerification();
                      Navigator.of(context).pushNamed(verifyEmailRoute);
                    } else {
                      DialogDisplay.showErrorDialog(context,
                          'Leider sind Sie nicht in unserem System gespeichert. Bitte überprüfen Sie noch einmal Ihre E-Mail Adresse.');
                    }
                  } on WeakPasswordAuthException {
                    await DialogDisplay.showErrorDialog(context,
                        'Password zu schwach. Bitte erstellen Sie ein Passwort aus mindestens 6 Zeichen.');
                  } on EmailAlreadyInUseAuthException {
                    await DialogDisplay.showErrorDialog(context,
                        'Es existiert bereits ein verifizierter Nutzer mit dieser E-Mail Adresse.');
                  } //TODO: Vergleich mit Mac
                  on NoInternetAuthException {
                    await DialogDisplay.showErrorDialog(context,
                        'Es besteht keine Internetverbindung. Bitte stellen Sie eine Internetverbindung her und versuchen Sie es erneut.');
                  } on GenericAuthException {
                    await DialogDisplay.showErrorDialog(context,
                        'Es gab einen Fehler bei der Registrierung. Bitte versuchen Sie es später erneut.');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Text('Registrieren',
                      style: TextStyle(
                          fontSize: 16, color: Colors.blueGrey.shade700)),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text(
                    "Bereits registriert? Hier geht's zur Anmeldung!",
                    style: TextStyle(fontSize: 14.4)))
          ],
        )));
  }
}
