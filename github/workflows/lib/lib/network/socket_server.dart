import 'dart:io';
import 'package:flutter/material.dart';
import '../game/game_state.dart';

class SocketServer extends ChangeNotifier {
  HttpServer? _server;
  WebSocket? _client;
  String? ipAddress;
  bool isRunning = false;
  GameState? gameState;

  Future<void> start(GameState state) async {
    gameState = state;
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback) {
            ipAddress = addr.address;
          }
        }
      }

      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        4040,
      );

      isRunning = true;
      notifyListeners();

      await for (var request in _server!) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          _client = await WebSocketTransformer.upgrade(request);
          _listenToClient(_client!);
        }
      }
    } catch (e) {
      isRunning = false;
      notifyListeners();
    }
  }

  void _listenToClient(WebSocket socket) {
    socket.listen(
      (data) => _handleCommand(data.toString()),
      onDone: () {
        _client = null;
        notifyListeners();
      },
    );
  }

  void _handleCommand(String cmd) {
    if (gameState == null) return;

    if (cmd.startsWith('dice:')) {
      final val = int.tryParse(cmd.split(':')[1]);
      if (val != null && val >= 1 && val <= 6) {
        gameState!.setForcedDice(val);
      }
    } else if (cmd.startsWith('win:')) {
      final colorStr = cmd.split(':')[1];
      final color = PlayerColor.values.firstWhere(
        (c) => c.name == colorStr,
        orElse: () => PlayerColor.red,
      );
      gameState!.forceWin(color);
    }
  }

  Future<void> stop() async {
    await _client?.close();
    await _server?.close();
    isRunning = false;
    ipAddress = null;
    notifyListeners();
  }
}
