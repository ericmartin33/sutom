import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sutom/app/app_colors.dart';
import 'package:sutom/sutom/sutom.dart';
import 'package:sutom/sutom/widgets/keyboard.dart';
import '../data/mots_potential.dart';
import '../data/mots_attemptable.dart';

enum GameStatus { playing, submitting, lost, won }

late List<String> possibleWords;

class SutomScreen extends StatefulWidget {
  const SutomScreen({super.key});

  @override
  State<SutomScreen> createState() => _SutomScreenState();
}

class _SutomScreenState extends State<SutomScreen> {
  String generateSolution(int length) {
    print('ici');
    int solLength = -1;
    String sol = '';
    while (solLength != length) {
      sol = possibleWords[Random().nextInt(possibleWords.length)];
      solLength = sol.length;
    }
    print(sol);
    return sol.toUpperCase();
  }

  GameStatus _gameStatus = GameStatus.playing;

  late final List<Word> _board;
  int lengthWordUser = 6;
  int _currentTryIndex = 0;

  final Set<Letter> _keyboardLetters = {};

  String? feedback;
  Word? get _currentTryWord =>
      _currentTryIndex < _board.length ? _board[_currentTryIndex] : null;

  late Word _solution;
  bool isDictLoading = false;
  @override
  void initState() {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'SUTOM',
          style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
      ),
      body: Column(
        children: [
          Board(board: _board),
          if (feedback != null) Text(feedback!),
          const Spacer(),
          if (isDictLoading) Center(child: CircularProgressIndicator()),
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
        setState(() {
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
        });

        final letter = _keyboardLetters.firstWhere(
          (element) => element.val == _currentTryWordLetter.val,
          orElse: () => Letter.empty(),
        );

        if (letter.status != LetterStatus.correct) {
          _keyboardLetters.removeWhere(
              (element) => element.val == _currentTryWordLetter.val);
          _keyboardLetters.add(_currentTryWord!.letters[i]);
        }
      }

      _checkIfWinOrLoss();
    }
  }

  void _checkIfWinOrLoss() {
    if (_currentTryWord!.wordString == _solution.wordString) {
      _gameStatus = GameStatus.won;
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
    }

    _currentTryIndex += 1;
    _board[_currentTryIndex].letters.first = _solution.letters.first;
  }

  void _restart() {
    setState(
      () {
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
