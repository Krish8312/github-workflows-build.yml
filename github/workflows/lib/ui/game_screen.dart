import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';
import 'board_widget.dart';
import 'dice_widget.dart';

class GameScreen extends StatefulWidget {
  final int playerCount;
  const GameScreen({super.key, required this.playerCount});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().initGame(widget.playerCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B2FA0),
        title: const Text(
          'LUDO KING',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.read<GameState>().resetGame();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<GameState>(
        builder: (context, game, _) {
          if (game.phase == GamePhase.finished) {
            return _buildWinScreen(game);
          }
          return Column(
            children: [
              _buildPlayerBar(game),
              const Expanded(child: BoardWidget()),
              _buildBottomBar(game),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerBar(GameState game) {
    return Container(
      height: 50,
      color: const Color(0xFF2D1454),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: game.players.map((p) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6,
            ),
            decoration: BoxDecoration(
              color: p.isActive
                  ? _playerColor(p.color)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              p.name,
              style: TextStyle(
                color: p.isActive ? Colors.white : Colors.white38,
                fontWeight: p.isActive
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar(GameState game) {
    final current = game.players.isNotEmpty
        ? game.players[game.currentPlayerIndex]
        : null;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20, vertical: 12,
      ),
      color: const Color(0xFF2D1454),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            current != null ? '${current.name} ki baari' : '',
            style: const TextStyle(
              color: Colors.white70, fontSize: 14,
            ),
          ),
          DiceWidget(),
        ],
      ),
    );
  }

  Widget _buildWinScreen(GameState game) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text(
            '${game.winner?.name} Jeeta!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              game.resetGame();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B2FA0),
              padding: const EdgeInsets.symmetric(
                horizontal: 40, vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'PHIR KHELO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _playerColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red: return Colors.red;
      case PlayerColor.green: return Colors.green;
      case PlayerColor.yellow: return Colors.amber;
      case PlayerColor.blue: return Colors.blue;
    }
  }
}
