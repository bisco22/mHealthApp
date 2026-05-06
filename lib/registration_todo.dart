/*
* ##TODO##
* Implementazione del form di registrazione
* Funzione che permette di inviare una richiesta post per registrare un nuovo utente
* Gestire eventuali eccezioni (mail non valida, username già esistente)
* Consiglio, utilizzare i seguenti widget: Scaffold, IconButton, SingleChildScrollView, Form,
* TextFormField, ElevatedButton, TextButton, SnackBar
*/
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
            child: Column(
              children: [
                const Text("Campo per inserire username", style: TextStyle(color: Colors.black)),
                SizedBox(height: 10),
                const Text("Campo per inserire mail", style: TextStyle(color: Colors.black)),
                SizedBox(height: 10),
                const Text("Campo per inserire password", style: TextStyle(color: Colors.black)),
                SizedBox(width: double.infinity, height: 30),
                const Text("Pulsante per inviare dati a server", style: TextStyle(color: Colors.black)),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _launchManual(context),
                  icon: const Icon(Icons.help_outline, color: Colors.black),
                  label: const Text(
                    'Manuale API',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
      );
  }
}

Future<void> _launchManual(BuildContext context) async {
  final Uri url = Uri.parse('https://mhealthapp.onrender.com/api_manual');
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile aprire il manuale.')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: Nessun browser trovato.')),
      );
    }
  }
}