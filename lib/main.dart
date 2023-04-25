import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/firebase_options.dart';
import 'package:mein_digitaler_hausmeister/views/login_view.dart';
import 'package:mein_digitaler_hausmeister/views/register_view.dart';
import 'package:mein_digitaler_hausmeister/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
        ),
        home: const HomePage(),
        routes: {
          '/login/': (context) => const LoginView(),
          '/register/': (context) => const RegisterView()
        }),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              print(user);
              if (user != null) {
                user.reload();
                if (user.emailVerified) {
                  print('E-Mail verified.');
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
              return const Text('Done');
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
