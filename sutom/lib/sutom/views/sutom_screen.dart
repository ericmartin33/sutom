import 'dart:math';

import 'package:flutter/material.dart';
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

  final List<Word> _board = List.generate(
    6,
    (_) => Word(letters: List.generate(5, (_) => Letter.empty())),
  );

  int _currentTryIndex = 0;

  Word? get _currentTryWord =>
      _currentTryIndex < _board.length ? _board[_currentTryIndex] : null;

  Word _solution = Word.fromString(
    fiveLetterWords[Random().nextInt(fiveLetterWords.length)].toUpperCase(),
  );

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
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        //_currentTryWord?.removeLetter();
      });
    }
  }
}
