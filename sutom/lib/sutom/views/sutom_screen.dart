import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sutom/app/app_colors.dart';
import 'package:sutom/sutom/sutom.dart';
import 'package:sutom/sutom/widgets/keyboard.dart';
import '../data/mots_potential.dart';
import '../data/mots_attemptable.dart';
import '../widgets/alert_dialog.dart';
import 'settings_screen.dart';

enum GameStatus { playing, submitting, lost, won }

enum RankWordStatus { notRanking, ranking, ranked }

late List<String> possibleWords;

class SutomScreen extends StatefulWidget {
  const SutomScreen({super.key});

  @override
  State<SutomScreen> createState() => _SutomScreenState();
}

class _SutomScreenState extends State<SutomScreen> {
  String generateSolution(int length) {
    int solLength = -1;
    String sol = '';
    while (solLength != length) {
      sol = possibleWords[Random().nextInt(possibleWords.length)];
      solLength = sol.length;
    }

    return sol.toUpperCase();
  }

  GameStatus _gameStatus = GameStatus.playing;

  RankWordStatus _rankWordStatus = RankWordStatus.notRanking;

  late final List<Word> _board;
  int lengthWordUser = 6;
  int _currentTryIndex = 0;

  late List<String> _goodWordsUser;
  late List<String> _badWordsUser;

  final Set<Letter> _keyboardLetters = {};
  late final SharedPreferences prefs;
  String? feedback;
  Word? get _currentTryWord =>
      _currentTryIndex < _board.length ? _board[_currentTryIndex] : null;

  late Word _solution;
  bool isDictLoading = false;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    starter();
  }

  starter() async {
    prefs = await SharedPreferences.getInstance();
    _goodWordsUser = prefs.getStringList('_goodWordsUser') ?? [];
    _badWordsUser = prefs.getStringList('_badWordsUser') ?? [];
    possibleWords = potentialWords
        .where((element) => element.length == lengthWordUser)
        .toList();
    _solution = Word.fromString(generateSolution(lengthWordUser));
    _board = List.generate(
      6,
      (line) => Word(
          letters: List.generate(
              lengthWordUser,
              (row) => (row == 0 && line == 0)
                  ? _solution.letters.first
                  : Letter.empty())),
    );
    feedback = _solution.wordString;
    setState(() => isLoading = false);
  }

  restarter() async {
    _goodWordsUser = prefs.getStringList('_goodWordsUser') ?? [];
    _badWordsUser = prefs.getStringList('_badWordsUser') ?? [];
    possibleWords = potentialWords
        .where((element) => element.length == lengthWordUser)
        .toList();
    _solution = Word.fromString(generateSolution(lengthWordUser));
    _board
      ..clear()
      ..addAll(
        List.generate(
          6,
          (line) => Word(
              letters: List.generate(
                  lengthWordUser,
                  (row) => (row == 0 && line == 0)
                      ? _solution.letters.first
                      : Letter.empty())),
        ),
      );
    _keyboardLetters.clear();
    feedback = _solution.wordString;
    _currentTryIndex = 0;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
              child: Text('Sutom'),
            ),
            ListTile(
              title: const Text('Bons mots'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ListWordsDialog(
                      words: _goodWordsUser,
                    );
                  },
                ));
              },
            ),
            ListTile(
              title: const Text('Mauvais mots'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ListWordsDialog(
                      words: _badWordsUser,
                    );
                  },
                ));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'SUTOM',
          style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: (() async {
              int newWordLength = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsView(dropDownValue: lengthWordUser),
                ),
              );
              if (!mounted) return;
              print('here' + newWordLength.toString());
              lengthWordUser = newWordLength;
              isLoading = true;
              restarter();
            }),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Board(board: _board),
                if (feedback != null) Text(feedback!),
                if (_rankWordStatus == RankWordStatus.ranked)
                  const Text('Votre vote est pris en compte'),
                if (_rankWordStatus == RankWordStatus.ranking)
                  Column(
                    children: [
                      const Text('notez ce mot'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.thumb_up_sharp,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              _rankWord(prefs, true, _solution.wordString);
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              _rankWord(prefs, false, _solution.wordString);
                            },
                            icon: const Icon(
                              Icons.thumb_down_sharp,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                const Spacer(),
                if (isDictLoading)
                  const Center(child: CircularProgressIndicator()),
                Keyboard(
                  onKeyTap: _onKeyTap,
                  onDeleteTap: _onDeleteTap,
                  onEnterTap: _onEnterTap,
                  letters: _keyboardLetters,
                )
              ],
            ),
    );
  }

  void _onKeyTap(String val) {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        feedback = null;
        _currentTryWord?.addLetter(val);
      });
    }
  }

  void _onDeleteTap() {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        feedback = null;
        _currentTryWord?.removeLetter();
      });
    }
  }

  void _onEnterTap() {
    setState(() {
      feedback = null;
    });

    if (!fiveLettersWordsReachable.contains(_currentTryWord?.wordString)) {
      setState(() {
        feedback = 'Ce mot n\'existe pas !';
      });

      return;
    }
    if (_gameStatus == GameStatus.playing &&
        _currentTryWord != null &&
        !_currentTryWord!.letters.contains(Letter.empty())) {
      _gameStatus == GameStatus.playing;
      for (var i = 0; i < _currentTryWord!.letters.length; i++) {
        final _currentTryWordLetter = _currentTryWord!.letters[i];
        final _currentSolutionLetter = _solution.letters[i];

        if (_currentTryWordLetter == _currentSolutionLetter) {
          _currentTryWord!.letters[i] = _currentTryWordLetter.copyWith(
            status: LetterStatus.correct,
          );
        } else if (_solution.letters.contains(_currentTryWordLetter)) {
          _currentTryWord!.letters[i] = _currentTryWordLetter.copyWith(
            status: LetterStatus.inwWord,
          );
        } else {
          _currentTryWord!.letters[i] = _currentTryWordLetter.copyWith(
            status: LetterStatus.notInWord,
          );
        }
      }
      for (var i = 0; i < _currentTryWord!.letters.length; i++) {
        final currentTryWordLetter = _currentTryWord!.letters[i];

        if (currentTryWordLetter.status == LetterStatus.inwWord &&
            !isLeftLetterTofind(currentTryWordLetter.val)) {
          setState(() {
            _currentTryWord!.letters[i] = currentTryWordLetter.copyWith(
              status: LetterStatus.notInWord,
            );
          });
        }

        setState(() {
          _currentTryWord!.letters[i] = _currentTryWord!.letters[i];
        });

        final letter = _keyboardLetters.firstWhere(
          (element) => element.val == currentTryWordLetter.val,
          orElse: () => Letter.empty(),
        );

        if (letter.status != LetterStatus.correct) {
          _keyboardLetters.removeWhere(
              (element) => element.val == currentTryWordLetter.val);
          _keyboardLetters.add(_currentTryWord!.letters[i]);
        }
      }

      _checkIfWinOrLoss();
    }
  }

  bool isLeftLetterTofind(String letter) {
    int lettertofind = letter.allMatches(_solution.wordString).length;
    int letterFound = 0;

    for (int i = 0; i < _currentTryWord!.wordString.length; i++) {
      final currentTryWordLetter = _currentTryWord!.letters[i];
      if (currentTryWordLetter.val == letter &&
          currentTryWordLetter.status == LetterStatus.correct) {
        letterFound++;
      }
    }

    if (lettertofind > letterFound) {
      return true;
    }
    return false;
  }

  void _checkIfWinOrLoss() {
    if (_currentTryWord!.wordString == _solution.wordString) {
      _gameStatus = GameStatus.won;
      _rankWordStatus = RankWordStatus.ranking;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.none,
          duration: const Duration(days: 1),
          backgroundColor: correctColor,
          content: const Text(
            'Gagné ! ',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Rejouer',
            onPressed: _restart,
            textColor: Colors.white,
          ),
        ),
      );
    } else if (_currentTryIndex + 1 >= _board.length) {
      _rankWordStatus = RankWordStatus.ranking;
      _gameStatus = GameStatus.lost;
      _gameStatus = GameStatus.won;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.none,
          duration: const Duration(days: 1),
          backgroundColor: Colors.redAccent[200],
          content: Text(
            'Perdu! la solution était : ${_solution.wordString}',
            style: const TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Rejouer',
            onPressed: _restart,
            textColor: Colors.white,
          ),
        ),
      );
    } else {
      _gameStatus = GameStatus.playing;
      _currentTryIndex += 1;
      _board[_currentTryIndex].letters.first = _solution.letters.first;
    }
  }

  void _rankWord(SharedPreferences prefs, bool isGood, String word) async {
    if (isGood) {
      _goodWordsUser.add(word);
      await prefs.setStringList('_goodWordsUser', _goodWordsUser);
    } else {
      _badWordsUser.add(word);
      await prefs.setStringList('_badWordsUser', _badWordsUser);
    }

    setState(
      () {
        _rankWordStatus = RankWordStatus.ranked;
      },
    );
  }

  void _restart() {
    print('restart');
    setState(
      () {
        _rankWordStatus = RankWordStatus.notRanking;
        _gameStatus = GameStatus.playing;

        _currentTryIndex = 0;
        _solution = Word.fromString(generateSolution(lengthWordUser));
        _board
          ..clear()
          ..addAll(
            List.generate(
              6,
              (line) => Word(
                  letters: List.generate(
                      lengthWordUser,
                      (row) => (row == 0 && line == 0)
                          ? _solution.letters.first
                          : Letter.empty())),
            ),
          );
        _keyboardLetters.clear();
      },
    );
  }
}
