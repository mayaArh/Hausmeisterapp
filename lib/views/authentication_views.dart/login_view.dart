import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_exceptions.dart';
import 'package:mein_digitaler_hausmeister/services/auth/firebase_auth_provider.dart';
import '../../services/firestore_crud/firestore_data_service.dart';
import '../../utilities/show_dialog.dart';

/// This class is responsible for
/// displaying the login screen including possible error messages.
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
          title: const Text('Gebäudeservice Giebert'),
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
                      hintText: 'Passwort',
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
                        context, 'Der angegebene Benutzer existiert nicht.');
                  } on NoEmailProvidedAuthException {
                    await DialogDisplay.showErrorDialog(
                        context, 'Bitte geben Sie Ihre E-Mail-Adresse an.');
                  } on NoPasswordProvidedAuthException {
                    await DialogDisplay.showErrorDialog(
                        context, 'Bitte geben Sie Ihr Passwort an.');
                  } on WrongPasswordAuthException {
                    await DialogDisplay.showErrorDialog(
                        context, 'Falsches Passwort.');
                  } on NoInternetAuthException {
                    await DialogDisplay.showErrorDialog(
                        context, 'Bitte verbinden Sie sich mit dem Internet.');
                  } on GenericAuthException {
                    await DialogDisplay.showErrorDialog(context,
                        'Bei der Anmeldung ist ein unbekannter Fehler aufgetreten. Bitte versuchen Sie es später erneut.');
                  }
                },
                child: Padding(
                    padding: const EdgeInsets.all(11),
                    child: Text(
                      'Anmelden',
                      style: TextStyle(
                          fontSize: 16, color: Colors.blueGrey.shade600),
                    )),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute, (route) => false);
                  },
                  child: const Text(
                    "Noch nicht registriert? Hier geht's zur Registrierung!",
                    style: TextStyle(fontSize: 14.4),
                  ))
            ],
          ),
        ));
  }
}
