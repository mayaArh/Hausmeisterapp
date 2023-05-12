import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'package:mein_digitaler_hausmeister/views/login_view.dart';

import '../services/auth/auth_exceptions.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends State<RegisterView> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _streetname;
  late final TextEditingController _houseNumber;
  late final TextEditingController _flatNumber;
  late final TextEditingController _postalCode;
  late final TextEditingController _city;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _streetname = TextEditingController();
    _houseNumber = TextEditingController();
    _flatNumber = TextEditingController();
    _postalCode = TextEditingController();
    _city = TextEditingController();
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
        title: const Text('Registrieren'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _firstName,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: 'Vorname',
            ),
          ),
          TextField(
            controller: _lastName,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: 'Nachname',
            ),
          ),
          TextField(
            controller: _streetname,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.streetAddress,
            decoration: const InputDecoration(
              hintText: 'Straße',
            ),
          ),
          TextField(
            controller: _houseNumber,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.streetAddress,
            decoration: const InputDecoration(
              hintText: 'Hausnummer',
            ),
          ),
          TextField(
            controller: _flatNumber,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Wohnungsnummer',
            ),
          ),
          TextField(
            controller: _postalCode,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'PLZ',
            ),
          ),
          TextField(
            controller: _city,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: 'Ort',
            ),
          ),
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'E-Mail Adresse',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'App-Passwort',
            ),
          ),
          TextButton(
            onPressed: () async {
              final firstName = _firstName.text;
              final lastName = _lastName.text;
              final streetname = _streetname.text;
              final houseNumber = _houseNumber.value;
              final flatNumber = _flatNumber.value;
              final postalCode = _postalCode.value;
              final city = _city.text;
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                await AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                await showErrorDialog(context, 'Weak password');
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, 'E-Mail already in use');
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'Invalid E-Mail');
              } on GenericAuthException {
                await showErrorDialog(context, 'Failed to register');
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Already registered? Login here!'))
        ],
      ),
    );
  }
}
