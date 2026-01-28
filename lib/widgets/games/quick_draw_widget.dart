import 'dart:math';
import 'dart:ui' as ui;
import 'package:connect/api/apis.dart';
import 'package:connect/config/app_colors.dart';
import 'package:connect/models/chat_user.dart';
import 'package:connect/models/message.dart';
import 'package:flutter/material.dart';

class QuickDrawWidget extends StatefulWidget {
  final ChatUser opponent;

  const QuickDrawWidget({Key? key, required this.opponent}) : super(key: key);

  @override
  State<QuickDrawWidget> createState() => _QuickDrawWidgetState();
}

class _QuickDrawWidgetState extends State<QuickDrawWidget> {
  List<Offset?> points = [];
  String? currentWord;
  final GlobalKey _canvasKey = GlobalKey();

  final List<String> words = [
    'House', 'Car', 'Tree', 'Sun', 'Cat',
    'Dog', 'Flower', 'Star', 'Heart', 'Phone',
    'Book', 'Clock', 'Cup', 'Chair', 'Smile',
  ];

  @override
  void initState() {
    super.initState();
    _getNewWord();
  }

  void _getNewWord() {
    setState(() {
      currentWord = words[Random().nextInt(words.length)];
      points.clear();
    });
  }

  void _clearDrawing() {
    setState(() {
      points.clear();
    });
  }

  Future<void> _sendDrawing() async {
    if (points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw something first!')),
      );
      return;
    }

    Navigator.pop(context);

    await APIs.sendMessage(
      widget.opponent,
      '🎨 Quick Draw: $currentWord',
      Type.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00CEC9), Color(0xFF74B9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CEC9).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Draw',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _getNewWord,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Draw: $currentWord',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    points.add(details.localPosition);
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    points.add(details.localPosition);
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    points.add(null);
                  });
                },
                child: CustomPaint(
                  key: _canvasKey,
                  painter: DrawingPainter(points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearDrawing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _sendDrawing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00CEC9),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D3436)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}