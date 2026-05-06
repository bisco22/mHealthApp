import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'game_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _questions = [];
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showExplanation = false;
  String? _selectedOption;
  bool _isAnswerCorrect = false;

  int _bestScore = 0;
  int _totalScore = 0;
  int _attempts = 0;
  List<int> _scoreHistory = [];

  // Stato per la navigazione
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse('https://mhealthapp.onrender.com/quiz/random'));
      if (response.statusCode == 200) {
        setState(() {
          _questions = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Errore caricamento quiz: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitAnswer(String option) {
    if (_showExplanation) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    setState(() {
      _selectedOption = option;
      _isAnswerCorrect = option == currentQuestion['correct_option'];
      if (_isAnswerCorrect) _score++;
      _showExplanation = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showExplanation = false;
        _selectedOption = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final bool isPerfectScore = _score == _questions.length;
    setState(() {
      if (_score > _bestScore) _bestScore = _score;
      _totalScore += _score;
      _attempts++;
      _scoreHistory.add(_score);
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completato!'),
        content: Text(
          isPerfectScore
              ? 'Incredibile ${widget.username}! 🏆\nHai risposto correttamente a tutte le domande!'
              : 'Complimenti ${widget.username}!\nHai risposto correttamente a $_score su ${_questions.length} domande.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _showExplanation = false;
                _selectedOption = null;
                _isLoading = true;
              });
              _fetchQuestions();
            },
            child: const Text('RIFAI QUIZ'),
          ),
          if (isPerfectScore)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
              child: const Text('GIOCA A BIRDLE'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildUserView(),
      _buildQuizView(),
      _buildProgressView(),
    ];

    String getTitle() {
      switch (_selectedIndex) {
        case 0: return 'Il Tuo Profilo';
        case 1: return 'Quiz';
        case 2: return 'Statistiche';
        default: return 'mHealth';
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color.fromARGB(255, 45, 25, 35),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed, // Necessario per 3+ items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Statistiche',
          ),
        ],
      ),
    );
  }

  Widget _buildUserView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              widget.username,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Card(
              color: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, 'Email', 'admin@mhealth.com'),
                    const Divider(color: Colors.white12),
                    _buildInfoRow(Icons.emoji_events, 'Ultimo Punteggio', '$_score / ${_questions.length}'),
                    const Divider(color: Colors.white12),
                    _buildInfoRow(Icons.star, 'Record Personale', '$_bestScore'),
                    const Divider(color: Colors.white12),
                    _buildInfoRow(Icons.analytics, 'Media Risposte', _attempts == 0 ? '0' : (_totalScore / _attempts).toStringAsFixed(1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Andamento Performance',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visualizza i tuoi progressi nel tempo',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 32),
          if (_scoreHistory.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.query_stats, size: 80, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    const Text(
                      'Ancora nessun dato.\nCompleta un quiz per vedere il grafico!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildScoreChart(),
            const SizedBox(height: 32),
            _buildStatSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatSummary() {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Prove', _attempts.toString()),
            _buildStatItem('Media', _attempts == 0 ? '0' : (_totalScore / _attempts).toStringAsFixed(1)),
            _buildStatItem('Migliore', _bestScore.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildScoreChart() {
    return Container(
      height: 250, // Aumentato visto che ora ha la sua tab
      padding: const EdgeInsets.only(right: 24, left: 12, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: Colors.white12,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'P${value.toInt() + 1}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: _scoreHistory.length > 1 ? (_scoreHistory.length - 1).toDouble() : 1,
          minY: 0,
          maxY: 5,
          lineBarsData: [
            LineChartBarData(
              spots: _scoreHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.white,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 16),
          Text('$label: ', style: const TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_questions.isEmpty) {
      return const Center(child: Text('Nessuna domanda disponibile', style: TextStyle(color: Colors.white)));
    }

    final question = _questions[_currentQuestionIndex];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'DOMANDA ${_currentQuestionIndex + 1} DI ${_questions.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              question['question'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildOption('A', question['option_a']),
            _buildOption('B', question['option_b']),
            _buildOption('C', question['option_c']),
            _buildOption('D', question['option_d']),
            const SizedBox(height: 24),
            if (_showExplanation) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isAnswerCorrect
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isAnswerCorrect ? Colors.greenAccent : Colors.redAccent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isAnswerCorrect ? Icons.stars : Icons.info_outline,
                          color: _isAnswerCorrect ? Colors.greenAccent : Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isAnswerCorrect ? 'CORRETTO!' : 'UPS! SBAGLIATO',
                          style: TextStyle(
                            color: _isAnswerCorrect ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question['explanation'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromARGB(255, 45, 25, 35),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1 ? 'PROSSIMA DOMANDA' : 'VEDI RISULTATI',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String key, String text) {
    final bool isSelected = _selectedOption == key;
    final bool isCorrect = key == _questions[_currentQuestionIndex]['correct_option'];

    Color cardColor = Colors.white;
    Color borderSideColor = Colors.transparent;
    Color textColor = const Color.fromARGB(255, 45, 25, 35);

    if (_showExplanation) {
      if (isCorrect) {
        cardColor = Colors.green.shade100;
        borderSideColor = Colors.green;
      } else if (isSelected) {
        cardColor = Colors.red.shade100;
        borderSideColor = Colors.red;
      } else {
        cardColor = Colors.white.withValues(alpha: 0.5);
      }
    } else if (isSelected) {
      cardColor = Colors.white.withValues(alpha: 0.8);
      borderSideColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _submitAnswer(key),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderSideColor, width: 2),
            boxShadow: [
              if (isSelected && !_showExplanation)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? const Color.fromARGB(255, 45, 25, 35) : Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    key,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (_showExplanation && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green),
              if (_showExplanation && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
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
