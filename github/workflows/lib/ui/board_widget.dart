import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_state.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, game, _) {
        return AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 15,
              ),
              itemCount: 225,
              itemBuilder: (context, index) {
                return _buildCell(context, game, index);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(
      BuildContext context, GameState game, int index) {
    final row = index ~/ 15;
    final col = index % 15;
    final color = _getCellColor(row, col);
    final pieces = _getPiecesAt(game, row, col);

    return GestureDetector(
      onTap: () {
        if (pieces.isNotEmpty && game.diceRolled) {
          game.movePiece(pieces.first);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.black12,
            width: 0.3,
          ),
        ),
        child: pieces.isNotEmpty
            ? Center(child: _buildPiece(pieces.first))
            : null,
      ),
    );
  }

  Widget _buildPiece(Piece piece) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: _pieceColor(piece.color),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }

  List<Piece> _getPiecesAt(GameState game, int row, int col) {
    List<Piece> result = [];
    for (var player in game.players) {
      for (var piece in player.pieces) {
        if (!piece.isHome && !piece.isFinished) {
          final pos = _positionToCell(piece.position);
          if (pos != null && pos[0] == row && pos[1] == col) {
            result.add(piece);
          }
        }
      }
    }
    return result;
  }

  List<int>? _positionToCell(int position) {
    const path = [
      [6, 1], [6, 2], [6, 3], [6, 4], [6, 5],
      [5, 6], [4, 6], [3, 6], [2, 6], [1, 6],
      [0, 6], [0, 7], [0, 8], [1, 8], [2, 8],
      [3, 8], [4, 8], [5, 8], [6, 9], [6, 10],
      [6, 11], [6, 12], [6, 13], [6, 14], [7, 14],
      [8, 14], [8, 13], [8, 12], [8, 11], [8, 10],
      [8, 9], [9, 8], [10, 8], [11, 8], [12, 8],
      [13, 8], [14, 8], [14, 7], [14, 6], [13, 6],
      [12, 6], [11, 6], [10, 6], [9, 6], [8, 5],
      [8, 4], [8, 3], [8, 2], [8, 1], [8, 0],
      [7, 0], [6, 0], [7, 1], [7, 2], [7, 3],
      [7, 4], [7, 5], [7, 6],
    ];
    if (position < 0 || position >= path.length) return null;
    return path[position];
  }

  Color _getCellColor(int row, int col) {
    // Home zones
    if (row <= 5 && col <= 5) return const Color(0xFFE53935);
    if (row <= 5 && col >= 9) return const Color(0xFF43A047);
    if (row >= 9 && col <= 5) return const Color(0xFF1E88E5);
    if (row >= 9 && col >= 9) return const Color(0xFFFDD835);

    // Center
    if (row >= 6 && row <= 8 && col >= 6 && col <= 8) {
      return const Color(0xFF6B2FA0);
    }

    // Safe cells
    if ((row == 6 && col == 2) ||
        (row == 2 && col == 8) ||
        (row == 8 && col == 12) ||
        (row == 12 && col == 6)) {
      return const Color(0xFFFFCDD2);
    }

    return Colors.white;
  }

  Color _pieceColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red: return Colors.red;
      case PlayerColor.green: return Colors.green;
      case PlayerColor.yellow: return Colors.amber;
      case PlayerColor.blue: return Colors.blue;
    }
  }
}
