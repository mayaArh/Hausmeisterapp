import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/firebase_options.dart';
import 'package:mein_digitaler_hausmeister/views/login_view.dart';
import 'package:mein_digitaler_hausmeister/views/register_view.dart';
import 'package:mein_digitaler_hausmeister/views/verify_email_view.dart';
import 'dart:developer' as developer;

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
          '/register/': (context) => const RegisterView(),
          '/renter_home/': (context) => const RenterMainView()
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
              developer.log(user.toString());
              if (user != null) {
                user.reload();
                if (user.emailVerified) {
                  return const RenterMainView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

enum MenuEntry { logout }

class RenterMainView extends StatefulWidget {
  const RenterMainView({super.key});

  @override
  State<RenterMainView> createState() => _RenterMainViewState();
}

class _RenterMainViewState extends State<RenterMainView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuEntry>(
            onSelected: (value) async {
              switch (value) {
                case MenuEntry.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (_) => false);
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuEntry>(
                    value: MenuEntry.logout, child: Text('Log out'))
              ];
            },
          )
        ],
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out.'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Sign out.'))
          ],
        );
      }).then((value) => value ?? false);
}
