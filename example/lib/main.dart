import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BananaMania',
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  int bananaCount = 0;
  final Random random = Random();
  double bananaX = 0.5;
  double bananaY = 0.5;
  final double playAreaWidthFraction = 0.8; // 80% of the screen width
  final double playAreaHeightFraction = 0.6; // 60% of the screen height

  late AnimationController _animationController;
  late Animation<double> _animation;

  final double boxWidthFraction = 0.6; // 60% of the screen width
  final double boxHeightFraction = 0.4; // 40% of the screen height
  final double boxHorizontalOffsetFraction =
      0.2; // 20% from the left of the screen
  final double boxVerticalOffsetFraction =
      0.3; // 30% from the top of the screen

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween(begin: 1.0, end: 1.5).animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void collectBanana() {
    _animationController.forward();

    setState(() {
      bananaCount++;
      // Ensure the banana appears within the defined box area
      bananaX =
          random.nextDouble() * boxWidthFraction + boxHorizontalOffsetFraction;
      bananaY =
          random.nextDouble() * boxHeightFraction + boxVerticalOffsetFraction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(int.parse('0xFFB0D8E8')),
      // appBar: AppBar(
      //   title: Text('BananaMania'),
      // ),
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset('assets/jungle.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * bananaX,
            top: MediaQuery.of(context).size.height * bananaY,
            child: ScaleTransition(
              scale: _animation,
              child: GestureDetector(
                onTap: collectBanana,
                child: Image.asset('assets/banana.png', height: 30, width: 30),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    bananaCount == 0
                        ? 'Click on the banana'
                        : 'Bananas Collected: $bananaCount',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 130,
              width: 130,
              child: Image.asset('assets/monkey.png'),
            ), // Add your monkey image in assets
          ),
        ],
      ),
    );
  }
}
