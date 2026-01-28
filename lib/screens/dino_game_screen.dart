import 'dart:async';
import 'package:flutter/material.dart';

class DinoGameScreen extends StatefulWidget {
  const DinoGameScreen({Key? key}) : super(key: key);

  @override
  State<DinoGameScreen> createState() => _DinoGameScreenState();
}

class _DinoGameScreenState extends State<DinoGameScreen> {
  // Game state
  bool isGameStarted = false;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;

  // Dino properties
  double dinoY = 0;
  double dinoVelocity = 0;
  bool isJumping = false;
  final double gravity = 1.2;
  final double jumpPower = -18;
  final double dinoSize = 60;

  // Obstacle properties
  double obstacleX = 1.5;
  final double obstacleWidth = 50;
  final double obstacleHeight = 60;
  double obstacleSpeed = 0.02;

  // Ground position
  final double groundLevel = 0.75;

  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    setState(() {
      isGameStarted = true;
      isGameOver = false;
      score = 0;
      dinoY = 0;
      obstacleX = 1.5;
      obstacleSpeed = 0.02;
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    setState(() {
      // Update score (slower)
      score++;

      // Speed increases gradually
      obstacleSpeed = 0.02 + (score / 50000);

      // Update dino position (gravity)
      if (isJumping || dinoY < 0) {
        dinoVelocity += gravity;
        dinoY += dinoVelocity;

        // Ground collision
        if (dinoY >= 0) {
          dinoY = 0;
          dinoVelocity = 0;
          isJumping = false;
        }
      }

      // Move obstacle
      obstacleX -= obstacleSpeed;
      if (obstacleX < -0.3) {
        obstacleX = 1.5;
      }

      // Check collision
      if (checkCollision()) {
        gameOver();
      }
    });
  }

  bool checkCollision() {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Convert normalized positions to actual pixels
    double dinoLeftPixel = screenWidth * 0.1;
    double dinoRightPixel = dinoLeftPixel + dinoSize;
    double dinoTopPixel = (screenHeight * groundLevel) - dinoSize + dinoY;
    double dinoBottomPixel = dinoTopPixel + dinoSize;

    double obsLeftPixel = screenWidth * obstacleX;
    double obsRightPixel = obsLeftPixel + obstacleWidth;
    double obsTopPixel = (screenHeight * groundLevel) - obstacleHeight;
    double obsBottomPixel = obsTopPixel + obstacleHeight;

    // Check overlap with smaller hitbox for fairness
    bool xOverlap = (dinoRightPixel - 10) > (obsLeftPixel + 10) &&
        (dinoLeftPixel + 10) < (obsRightPixel - 10);
    bool yOverlap = (dinoBottomPixel - 10) > (obsTopPixel + 10) &&
        (dinoTopPixel + 10) < (obsBottomPixel - 10);

    return xOverlap && yOverlap;
  }

  void jump() {
    if (!isJumping && dinoY >= 0) {
      setState(() {
        isJumping = true;
        dinoVelocity = jumpPower;
      });
    }
  }

  void gameOver() {
    gameTimer?.cancel();
    setState(() {
      isGameOver = true;
      if (score > highScore) {
        highScore = score;
      }
    });
  }

  void resetGame() {
    startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isGameStarted ? 'Tap to jump!' : 'Tap to start',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Score: ${(score / 10).toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'High: ${(highScore / 10).toInt()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Game area
          Expanded(
            child: Stack(
              children: [
                // Ground line
                Align(
                  alignment: Alignment(0, groundLevel),
                  child: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                ),

                // Dino
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 0),
                  left: size.width * 0.1,
                  bottom: (size.height * (1 - groundLevel)) - dinoY,
                  child: Container(
                    width: dinoSize,
                    height: dinoSize,
                    child: const Center(
                      child: Text(
                        '🦖',
                        style: TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                ),

                // Obstacle
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 0),
                  left: size.width * obstacleX,
                  bottom: (size.height * (1 - groundLevel)),
                  child: Container(
                    width: obstacleWidth,
                    height: obstacleHeight,
                    child: const Center(
                      child: Text(
                        '🌵',
                        style: TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                ),

                // Game Over overlay
                if (isGameOver)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Game Over!',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Score: ${(score / 10).toInt()}',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: resetGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'Play Again',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Jump button and instructions
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (!isGameStarted)
                    const Column(
                      children: [
                        Icon(Icons.touch_app, size: 40, color: Colors.black54),
                        SizedBox(height: 10),
                        Text(
                          'Tap the button or screen to jump',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  // Jump Button
                  GestureDetector(
                    onTap: () {
                      if (!isGameStarted) {
                        startGame();
                      } else if (!isGameOver) {
                        jump();
                      } else {
                        resetGame();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}