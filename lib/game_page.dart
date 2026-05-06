import 'package:flutter/material.dart';
import 'game.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Game _game = Game();
  bool _isLoading = true;
  late final TextEditingController _guessController;

  @override
  void initState() {
    super.initState();
    _guessController = TextEditingController();
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
        title: const Text('Birdle'),
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
      duration: const Duration(milliseconds: 500),
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class GuessInput extends StatelessWidget {
  const GuessInput({super.key, required this.onSubmitGuess, required this.controller});

  final Future<void> Function(String) onSubmitGuess;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color.fromARGB(255, 45, 25, 35),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 8,
        ),
        decoration: const InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(35))),
        ),
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (i == 2)
                _KeyboardControlKey(label: 'ENTER', onTap: onEnter),
              for (final char in _rows[i])
                KeyButton(
                  char: char,
                  status: letterStatuses[char] ?? HitType.none,
                  onTap: () => onKeyTap(char),
                ),
              if (i == 2)
                _KeyboardControlKey(icon: Icons.backspace_outlined, onTap: onBackspace),
            ],
          ),
      ],
    );
  }
}

class _KeyboardControlKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeyboardControlKey({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: label != null
                ? Text(label!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                : Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }
}

class KeyButton extends StatelessWidget {
  final String char;
  final HitType status;
  final VoidCallback onTap;

  const KeyButton({
    super.key,
    required this.char,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      HitType.hit => Colors.green,
      HitType.partial => Colors.yellow,
      HitType.miss => Colors.grey.shade700,
      _ => Colors.grey.shade300,
    };

    final textColor = (status == HitType.miss || status == HitType.hit) ? Colors.white : Colors.black;

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
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}