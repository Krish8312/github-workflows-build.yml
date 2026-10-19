import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() =>
      _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  WebSocketChannel? _channel;
  final _ipController = TextEditingController();
  bool _connected = false;
  String _status = 'Connect karo pehle';

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${_ipController.text}:4040'),
      );
      setState(() {
        _connected = true;
        _status = 'Connected ✓';
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  void _send(String cmd) {
    if (!_connected) return;
    _channel?.sink.add(cmd);
  }

  void _disconnect() {
    _channel?.sink.close();
    setState(() {
      _connected = false;
      _status = 'Disconnected';
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B2FA0),
        title: const Text(
          'CONTROLLER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1454),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _ipController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Game Phone ka IP',
                      labelStyle:
                          const TextStyle(color: Colors.white60),
                      hintText: '192.168.1.5',
                      hintStyle:
                          const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: const Color(0xFF1A0A2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _connected ? null : _connect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF6B2FA0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'CONNECT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _connected ? _disconnect : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'DISCONNECT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: TextStyle(
                      color: _connected
                          ? Colors.greenAccent
                          : Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Dice Control
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1454),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DICE FORCE',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) {
                      final n = i + 1;
                      return GestureDetector(
                        onTap: () => _send('dice:$n'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _connected
                                ? Colors.white
                                : Colors.white24,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _diceFace(n),
                              style:
                                  const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Win Control
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1454),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FORCE WIN',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3,
                    children: [
                      _winButton('RED', 'red', Colors.red),
                      _winButton('GREEN', 'green', Colors.green),
                      _winButton('YELLOW', 'yellow', Colors.amber),
                      _winButton('BLUE', 'blue', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _winButton(String label, String cmd, Color color) {
    return ElevatedButton(
      onPressed: _connected ? () => _send('win:$cmd') : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  String _diceFace(int value) {
    switch (value) {
      case 1: return '⚀';
      case 2: return '⚁';
      case 3: return '⚂';
      case 4: return '⚃';
      case 5: return '⚄';
      case 6: return '⚅';
      default: return '🎲';
    }
  }
}
