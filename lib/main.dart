import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be My Valentine',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFFE5EC),
      ),
      home: const ValentinePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ValentinePage extends StatefulWidget {
  const ValentinePage({super.key});

  @override
  State<ValentinePage> createState() => _ValentinePageState();
}

class _ValentinePageState extends State<ValentinePage>
    with TickerProviderStateMixin {
  bool showSuccess = false;
  int clickCount = 0;
  double noBtnSize = 1.0;
  double yesBtnSize = 1.0;
  Offset noBtnPosition = Offset.zero;
  String noBtnText = 'No';
  double noBtnOpacity = 1.0;

  final List<FallingImage> fallingImages = [];
  Timer? fallingTimer;

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _celebrateController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    // Pulse animation for title
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Float animation for emoji
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Celebrate animation for success
    _celebrateController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Start falling images
    startFallingImages();
  }

  void startFallingImages() {
    fallingTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          fallingImages.add(FallingImage(
            left: Random().nextDouble(),
            duration: Random().nextDouble() * 3 + 4,
            size: Random().nextDouble() * 40 + 60,
          ));

          // Remove old images
          if (fallingImages.length > 20) {
            fallingImages.removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _celebrateController.dispose();
    _sparkleController.dispose();
    fallingTimer?.cancel();
    super.dispose();
  }

  void handleNoClick() {
    setState(() {
      clickCount++;

      // DON'T shrink too much
      noBtnSize -= 0.05;
      if (noBtnSize < 0.6) noBtnSize = 0.6;

      // Move button - SMALLER range so it stays visible
      final random = Random();
      noBtnPosition = Offset(
        (random.nextDouble() - 0.5) * 100,
        (random.nextDouble() - 0.5) * 50,
      );

      // Make Yes button bigger
      yesBtnSize = 1 + (clickCount * 0.15);

      // Change text
      if (clickCount == 3) {
        noBtnText = 'Please? 🥺';
      }
      if (clickCount == 5) {
        noBtnText = 'Really? 💔';
      }
      if (clickCount == 7) {
        noBtnText = 'Fine... 😢';
        noBtnOpacity = 0.3;
      }
    });
  }

  void handleYesClick() {
    setState(() {
      showSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D), // Hot pink
              Color(0xFFFFC2D4), // Light pink
              Color(0xFFFFE5EC), // Very light pink
            ],
          ),
        ),
        child: Stack(
          children: [
            // Falling images
            ...fallingImages.map((img) => FallingImageWidget(
                  fallingImage: img,
                  imageUrl: 'test.png',
                )),

            // Sparkles overlay
            ...List.generate(15, (index) => _buildSparkle(index)),

            // Main content
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFF69B4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1493).withOpacity(0.3),
                      blurRadius: 60,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: showSuccess ? _buildSuccessScreen() : _buildQuestionScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkle(int index) {
    final random = Random(index);
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final offset = (_sparkleController.value + (index * 0.1)) % 1.0;
        return Positioned(
          left: MediaQuery.of(context).size.width * random.nextDouble(),
          top: MediaQuery.of(context).size.height * random.nextDouble(),
          child: Opacity(
            opacity: (sin(offset * 2 * pi) + 1) / 2,
            child: Icon(
              Icons.star,
              color: const Color(0xFFFFD700),
              size: 15 + random.nextDouble() * 15,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heart decoration
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💕', style: TextStyle(fontSize: 30)),
            SizedBox(width: 10),
            Text('💖', style: TextStyle(fontSize: 35)),
            SizedBox(width: 10),
            Text('💕', style: TextStyle(fontSize: 30)),
          ],
        ),
        const SizedBox(height: 20),

        // Pulsing title
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.05).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
          ),
          child: const Text(
            '💝 Will You Be My\nValentine? 💝',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF1493),
              fontSize: 40,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Color(0xFFFFB6C1),
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Floating image with pink glow
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -0.2),
          ).animate(
            CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: Image.network(
              'https://i.imgur.com/h9Yz0Sg.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  '❤️',
                  style: TextStyle(fontSize: 150),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Romantic text
        const Text(
          '💌 Pag balik nakoo mag date ta hehe 💌',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFFF69B4),
            fontSize: 16,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 30),

        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Yes Button with sparkle effect
            Transform.scale(
              scale: yesBtnSize,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1493).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: handleYesClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1493),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Yes! 💕',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // No Button
            Transform.translate(
              offset: noBtnPosition,
              child: Transform.scale(
                scale: noBtnSize,
                child: Opacity(
                  opacity: noBtnOpacity,
                  child: ElevatedButton(
                    onPressed: handleNoClick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD3D3D3),
                      foregroundColor: const Color(0xFF808080),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      noBtnText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Celebrating hearts
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💕', style: TextStyle(fontSize: 40)),
            SizedBox(width: 10),
            Text('💖', style: TextStyle(fontSize: 50)),
            SizedBox(width: 10),
            Text('💕', style: TextStyle(fontSize: 40)),
          ],
        ),
        const SizedBox(height: 20),

        // Celebrating emoji
        RotationTransition(
          turns: Tween<double>(begin: -0.03, end: 0.03).animate(
            CurvedAnimation(parent: _celebrateController, curve: Curves.easeInOut),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: const Text(
              '🎉',
              style: TextStyle(fontSize: 120),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Success title
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.05).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
          ),
          child: const Text(
            '💗 Yay! You said YES! 💗',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF1493),
              fontSize: 40,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Color(0xFFFFB6C1),
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Success GIF
        Image.network(
          'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExajFiOTRma2F0bjA1MHA0MWxrdGd0MmY3cmxzeXN1aW5qazNocGJvcSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/cbD4NSXZutjebF8cd8/giphy.gif',
          width: 200,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5EC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF69B4),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: const Text(
                '💕 This is the best day ever!\nI promise to cherish every moment with you! 💕',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFF1493),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Dancing hearts
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❤️', style: TextStyle(fontSize: 35)),
            SizedBox(width: 15),
            Text('💖', style: TextStyle(fontSize: 40)),
            SizedBox(width: 15),
            Text('💝', style: TextStyle(fontSize: 40)),
            SizedBox(width: 15),
            Text('💗', style: TextStyle(fontSize: 40)),
            SizedBox(width: 15),
            Text('❤️', style: TextStyle(fontSize: 35)),
          ],
        ),
      ],
    );
  }
}

class FallingImage {
  final double left;
  final double duration;
  final double size;

  FallingImage({
    required this.left,
    required this.duration,
    required this.size,
  });
}

class FallingImageWidget extends StatefulWidget {
  final FallingImage fallingImage;
  final String imageUrl;

  const FallingImageWidget({
    super.key,
    required this.fallingImage,
    required this.imageUrl,
  });

  @override
  State<FallingImageWidget> createState() => _FallingImageWidgetState();
}

class _FallingImageWidgetState extends State<FallingImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (widget.fallingImage.duration * 1000).toInt()),
      vsync: this,
    );

    _animation = Tween<double>(begin: -0.2, end: 1.2).animate(_controller);
    _controller.forward();
    
    // Repeat animation when it completes - WITH mounted check to prevent disposed view error
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _controller.reset();
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * widget.fallingImage.left,
          top: MediaQuery.of(context).size.height * _animation.value,
          child: Opacity(
            opacity: 0.8,
            child: Transform.rotate(
              angle: _animation.value * 2 * pi,
              child: Image.asset(
                widget.imageUrl,
                width: widget.fallingImage.size,
                height: widget.fallingImage.size,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: widget.fallingImage.size,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}