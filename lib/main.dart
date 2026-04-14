import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sfondo scelto da te (Rosa Antico)
    const Color backgroundColor = Color.fromARGB(65, 139, 95, 114);

    // Prugna molto scuro per i dettagli (pulsanti, icone, testi nei campi)
    const Color primaryDeepColor = Color.fromARGB(255, 45, 25, 35);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryDeepColor,
          primary: primaryDeepColor,
          // Colore del testo su superfici chiare (come i campi di input)
          onSurface: primaryDeepColor,
        ),

        // Stile dei pulsanti: testo bianco su fondo scuro
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDeepColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),

        // Stile dei campi di testo: scritte scure su fondo bianco
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryDeepColor, width: 2),
          ),
          // Testo dell'etichetta scuro quando è dentro il campo bianco
          labelStyle: const TextStyle(color: primaryDeepColor, fontWeight: FontWeight.bold),
          // L'etichetta diventa bianca quando il campo viene selezionato (focalizzato)
          floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const TextStyle(color: primaryDeepColor, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: primaryDeepColor, fontWeight: FontWeight.bold);
          }),
          // Testo di errore bianco per contrasto con lo sfondo rosa
          errorStyle: const TextStyle(color: Colors.white),
          prefixIconColor: primaryDeepColor,
        ),

        // AppBar con titolo in bianco puro per massima visibilità
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// Nuova pagina Home
class HomePage extends StatelessWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Benvenuto, $username!',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.verified_user, size: 100, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  static const _correctUsername = 'Admin';
  static const _correctPassword = 'Admin1234';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final isCorrect = _usernameController.text == _correctUsername &&
          _passwordController.text == _correctPassword;

      if (isCorrect) {
        // Naviga alla HomePage e rimuove la pagina di login dallo stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(username: _usernameController.text)),
        );
      } else {
        // Mostra errore solo se le credenziali sono sbagliate
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Accesso fallito'),
            content: const Text('Le credenziali inserite non sono corrette.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('RIPROVA'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bentornato')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 110,
                  color: Colors.white,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  // Stile del testo inserito (deve essere scuro sul campo bianco)
                  style: const TextStyle(color: Color.fromARGB(255, 45, 25, 35)),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci lo username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  // Stile del testo inserito (deve essere scuro sul campo bianco)
                  style: const TextStyle(color: Color.fromARGB(255, 45, 25, 35)),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la password';
                    }
                    if (value.length < 6) {
                      return 'Minimo 6 caratteri';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text(
                      'ACCEDI',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Non hai un account?',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Registrati',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea Account')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.app_registration_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Pagina di Registrazione',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
              child: const Text('Torna al Login'),
            ),
          ],
        ),
      ),
    );
  }
}