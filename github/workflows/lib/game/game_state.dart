import 'package:flutter/material.dart';
import 'dart:math';

enum PlayerColor { red, green, yellow, blue }
enum GamePhase { waiting, playing, finished }

class Piece {
  final PlayerColor color;
  final int id;
  int position;
  bool isHome;
  bool isFinished;

  Piece({
    required this.color,
    required this.id,
    this.position = -1,
    this.isHome = true,
    this.isFinished = false,
  });
}

class Player {
  final PlayerColor color;
  final String name;
  List<Piece> pieces;
  bool isActive;

  Player({
    required this.color,
    required this.name,
    this.isActive = false,
  }) : pieces = List.generate(
          4,
          (i) => Piece(color: color, id: i),
        );
}

class GameState extends ChangeNotifier {
  List<Player> players = [];
  int currentPlayerIndex = 0;
  int diceValue = 0;
  bool diceRolled = false;
  GamePhase phase = GamePhase.waiting;
  Player? winner;

  // Controller override
  int? forcedDice;
  PlayerColor? forcedWinner;

  final Random _random = Random();

  void initGame(int playerCount) {
    players = [
      Player(color: PlayerColor.red, name: 'Player 1'),
      Player(color: PlayerColor.green, name: 'Player 2'),
      if (playerCount >= 3)
        Player(color: PlayerColor.yellow, name: 'Player 3'),
      if (playerCount == 4)
        Player(color: PlayerColor.blue, name: 'Player 4'),
    ];
    players[0].isActive = true;
    phase = GamePhase.playing;
    notifyListeners();
  }

  void rollDice() {
    if (diceRolled) return;
    if (forcedDice != null) {
      diceValue = forcedDice!;
      forcedDice = null;
    } else {
      diceValue = _random.nextInt(6) + 1;
    }
    diceRolled = true;
    notifyListeners();
  }

  void movePiece(Piece piece) {
    if (!diceRolled) return;
    Player current = players[currentPlayerIndex];

    if (piece.isHome && diceValue == 6) {
      piece.isHome = false;
      piece.position = _getStartPosition(piece.color);
    } else if (!piece.isHome && !piece.isFinished) {
      piece.position += diceValue;
      if (piece.position >= 57) {
        piece.isFinished = true;
      }
    }

    if (_checkWin(current)) {
      winner = current;
      phase = GamePhase.finished;
      notifyListeners();
      return;
    }

    if (diceValue != 6) {
      _nextPlayer();
    } else {
      diceRolled = false;
    }
    notifyListeners();
  }

  bool _checkWin(Player player) {
    return player.pieces.every((p) => p.isFinished);
  }

  void _nextPlayer() {
    players[currentPlayerIndex].isActive = false;
    currentPlayerIndex =
        (currentPlayerIndex + 1) % players.length;
    players[currentPlayerIndex].isActive = true;
    diceRolled = false;
  }

  int _getStartPosition(PlayerColor color) {
    switch (color) {
      case PlayerColor.red: return 1;
      case PlayerColor.green: return 15;
      case PlayerColor.yellow: return 29;
      case PlayerColor.blue: return 43;
    }
  }

  // Controller functions
  void setForcedDice(int value) {
    forcedDice = value;
    notifyListeners();
  }

  void forceWin(PlayerColor color) {
    for (var player in players) {
      if (player.color == color) {
        for (var piece in player.pieces) {
          piece.isFinished = true;
          piece.isHome = false;
        }
        winner = player;
        phase = GamePhase.finished;
        break;
      }
    }
    notifyListeners();
  }

  void resetGame() {
    players = [];
    currentPlayerIndex = 0;
    diceValue = 0;
    diceRolled = false;
    phase = GamePhase.waiting;
    winner = null;
    notifyListeners();
  }
}
