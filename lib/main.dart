import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'constants/routes.dart';
import 'views/administration_views/login_view.dart';
import 'views/administration_views/register_view.dart';
import 'views/administration_views/tickets_overview.dart';
import 'views/verify_email_view.dart';
import 'dart:developer' as developer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        ticketOverviewRoute: (context) => const TicketOverview(),
        verifyEmailRoute: (context) => const VerifyEmailView()
      });
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              developer.log(user.toString());
              if (user != null) {
                if (user.isEmailVerified) {
                  return const TicketOverview();
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
