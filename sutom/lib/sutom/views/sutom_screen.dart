import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sutom/app/app_colors.dart';
import 'package:sutom/sutom/sutom.dart';
import 'package:sutom/sutom/widgets/keyboard.dart';
import '../data/word_list.dart';

enum GameStatus { playing, submitting, lost, won }

class SutomScreen extends StatefulWidget {
  const SutomScreen({super.key});

  @override
  State<SutomScreen> createState() => _SutomScreenState();
}

class _SutomScreenState extends State<SutomScreen> {
  GameStatus _gameStatus = GameStatus.playing;

  late final List<Word> _board;

  int _currentTryIndex = 0;

  Word? get _currentTryWord =>
      _currentTryIndex < _board.length ? _board[_currentTryIndex] : null;

  Word _solution = Word.fromString(
    fiveLetterWords[Random().nextInt(fiveLetterWords.length)].toUpperCase(),
  );
  @override
  void initState() {
    _board = List.generate(
      6,
      (line) => Word(
          letters: List.generate(
              5,
              (row) => (row == 0 && line == 0)
                  ? _solution.letters.first
                  : Letter.empty())),
    );
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
          Spacer(),
          Keyboard(
              onKeyTap: _onKeyTap,
              onDeleteTap: _onDeleteTap,
              onEnterTap: _onEnterTap)
        ],
      ),
    );
  }

  void _onKeyTap(String val) {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        _currentTryWord?.addLetter(val);
      });
    }
  }

  void _onDeleteTap() {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        _currentTryWord?.removeLetter();
      });
    }
  }

  void _onEnterTap() {
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
            style: TextStyle(color: Colors.white),
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
        _board
          ..clear()
          ..addAll(
            List.generate(6,
                (_) => Word(letters: List.generate(5, (_) => Letter.empty()))),
          );

        _solution = Word.fromString(
            fiveLetterWords[Random().nextInt(fiveLetterWords.length)]
                .toUpperCase());
      },
    );
  }
}
