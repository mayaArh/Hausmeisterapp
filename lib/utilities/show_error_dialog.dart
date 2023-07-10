import 'package:flutter/material.dart';

//displays error dialog
class DialogDisplay {
  static Future<void> showErrorDialog(BuildContext context, String text) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Fehlermeldung'),
            content: Text(text),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }

  static Future<bool> showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Ausloggen.'),
            content: const Text('Sind sie sicher?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Abbrechen')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Ausloggen'))
            ],
          );
        }).then((value) => value ?? false);
  }
}
