import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sfondo scelto da te (Rosa Antico)
    const Color backgroundColor = Color.fromARGB(255, 139, 95, 114);

    // Prugna molto scuro per i dettagli (pulsanti, icone, testi nei campi)
    const Color primaryDeepColor = Color.fromARGB(255, 45, 25, 35);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo - v1.0',
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
            //backgroundColor: primaryDeepColor,
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
  bool _isLoading = false;

  static const _correctUsername = 'Admin';
  static const _correctPassword = 'Admin1234';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    //Simuliamo la richiesta a un DB per vedere come funziona l'async/await
    if (_formKey.currentState!.validate()) {
      final isCorrect = _usernameController.text == _correctUsername &&
          _passwordController.text == _correctPassword;
      setState((){
        _isLoading = true;
      });
      await Future.delayed(Duration(seconds:2));

      if (isCorrect) {
        // Naviga alla HomePage e rimuove la pagina di login dallo stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(username: _usernameController.text)),
        );
      } else {
        setState((){
          _isLoading = false;
        });
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
      appBar: AppBar(
        title: const Text('Bentornato'),
        bottom: _isLoading
            ? const PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: LinearProgressIndicator(
            minHeight: 4,
          ),
        )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Semantics(
              child:const Icon(
                  Icons.account_circle,
                  size: 110,
                  color: Colors.white,
                ),
                  label: "Icona dell'immagine profilo"
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Passa alla Cupertino Mode',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CupertinoPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Clicca Qui',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Gioca a Wordle',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Clicca Qui',
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
                backgroundColor: Colors.white,
              ),
              child: const Text('Torna al Login', style:TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),

            ),
          ],
        ),
      ),
    );
  }
}


class CupertinoPage extends StatelessWidget {
  const CupertinoPage({super.key});

  // This shows a CupertinoModalPopup which hosts a CupertinoActionSheet.
  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Title'),
        message: const Text('Message'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would be a default
            /// default behavior, turns the action's text to bold text.
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Default Action'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Action'),
          ),
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Destructive Action'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('La mia app'),
        ),
        child: Center(
          child: CupertinoButton.filled(
            onPressed: () => _showActionSheet(context),
            child: const Text('Bottone Cupertino'),
          ),
        ),
      );
  }
}


class GamePage extends StatefulWidget {
  GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Game _game = Game();
  final TextEditingController _guessController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  Future<void> _initGame() async {
    await _game.resetGame();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showQuickDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return AlertDialog(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  Future<void> _handleGuess(String guessText) async {
    if (guessText.length < 5) {
      _showQuickDialog('La parola deve essere lunga 5');
      return;
    }

    // Verifica se la parola è valida tramite il server
    final isLegal = await _game.isLegalGuess(guessText);

    if (isLegal) {
      setState(() {
        _game.guess(guessText);
        _guessController.clear();
      });
    } else {
      if (mounted) {
        _showQuickDialog('La parola non è nella lista');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parolale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => _isLoading = true);
              _guessController.clear();
              await _game.resetGame();
              setState(() => _isLoading = false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    for (var guess in _game.guesses)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var letter in guess)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                              child: Tile(letter.char, letter.type),
                            )
                        ],
                      ),
                    if (!_game.didWin && !_game.didLose) ...[
                      GuessInput(
                        controller: _guessController,
                        onSubmitGuess: (String guessText) async {
                          await _handleGuess(guessText);
                        },
                      ),
                      const SizedBox(height: 10),
                      Keyboard(
                        letterStatuses: _game.letterStatuses,
                        onKeyTap: (char) {
                          if (_guessController.text.length < 5) {
                            setState(() {
                              _guessController.text += char.toUpperCase();
                            });
                          }
                        },
                        onBackspace: () {
                          if (_guessController.text.isNotEmpty) {
                            setState(() {
                              _guessController.text = _guessController.text
                                  .substring(0, _guessController.text.length - 1);
                            });
                          }
                        },
                        onEnter: () async {
                          await _handleGuess(_guessController.text);
                        },
                      ),
                    ],
                    if (_game.didWin)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Hai Vinto! 🎉',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (_game.didLose)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Hai Perso! La parola era: ${_game.hiddenWord.toString().toUpperCase()}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}




class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  final String letter;
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.bounceIn, // NEW
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: switch (hitType) {
          HitType.hit => Colors.green,
          HitType.partial => Colors.yellow,
          HitType.miss => Colors.grey,
          _ => Colors.white,
        },
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}



class GuessInput extends StatelessWidget {
  GuessInput({super.key, required this.onSubmitGuess, required this.controller});

  final Future<void> Function(String) onSubmitGuess;
  final TextEditingController controller;

  final FocusNode _focusNode = FocusNode();

  Future<void> _onSubmit() async {
    final text = controller.text;
    await onSubmitGuess(text);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: TextField(
              maxLength: 5,
              focusNode: _focusNode,
              autofocus: true,
              readOnly: true, // Impedisce la comparsa della tastiera di sistema
              showCursor: true,
              keyboardType: TextInputType.none,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 45, 25, 35),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                ),
              ),
              controller: controller,
            ),
          ),
        ),
      ],
    );
  }
}

class Keyboard extends StatelessWidget {
  const Keyboard({
    super.key,
    required this.letterStatuses,
    required this.onKeyTap,
    required this.onBackspace,
    required this.onEnter,
  });

  final Map<String, HitType> letterStatuses;
  final ValueSetter<String> onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onEnter;

  static const _rows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (i == 2)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: GestureDetector(
                      onTap: onEnter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'ENTER',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                for (final char in _rows[i])
                  KeyButton(
                    char: char,
                    status: letterStatuses[char] ?? HitType.none,
                    onTap: () => onKeyTap(char),
                  ),
                if (i == 2)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: GestureDetector(
                      onTap: onBackspace,
                      child: Container(
                        width: 40,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.backspace_outlined, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class KeyButton extends StatelessWidget {
  const KeyButton({
    super.key,
    required this.char,
    required this.status,
    required this.onTap,
  });

  final String char;
  final HitType status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      HitType.hit => Colors.green,
      HitType.partial => Colors.yellow,
      HitType.miss => Colors.grey.shade700,
      _ => Colors.grey.shade300,
    };

    final textColor = (status == HitType.miss || status == HitType.hit)
        ? Colors.white
        : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 45,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              char.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
