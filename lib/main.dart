import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'ai_chat.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: const WheelOfFortune(),
    );
  }
}

class WheelOfFortune extends StatefulWidget {
  const WheelOfFortune({super.key});

  @override
  State<WheelOfFortune> createState() => _WheelOfFortuneState();
}

class _WheelOfFortuneState extends State<WheelOfFortune>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _wheelController;
  Animation<double>? _wheelAnimation;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<String> options = ['A', 'B', 'C', 'D'];
  
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.lime,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.brown,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.cyanAccent,
    Colors.amberAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
    Colors.indigoAccent,
    Colors.limeAccent,
    Colors.deepOrangeAccent,
    Colors.lightBlueAccent,
    Colors.lightGreenAccent,
    Colors.deepPurpleAccent,
  ];
  
  bool _isSpinning = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    
    // Animacja tła
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Animacja koła
    _wheelController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _wheelController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _spinWheel() async {
    if (_isSpinning) return;
    
    // Odtwórz dźwięk kręcenia koła
    try {
      await _audioPlayer.play(AssetSource('sounds/spin.mp3'));
    } catch (e) {
      print('Błąd odtwarzania dźwięku: $e');
    }
    
    setState(() {
      _isSpinning = true;
      _selectedOption = null;
    });

    final random = Random();
    final spins = 5 + random.nextDouble() * 3; // 5-8 obrotów
    final extraAngle = random.nextDouble() * 2 * pi;
    
    final totalRotation = spins * 2 * pi + extraAngle;
    
    _wheelAnimation = Tween<double>(
      begin: 0,
      end: totalRotation,
    ).animate(CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutCubic,
    ));

    _wheelController.forward(from: 0).then((_) async {
      // Zatrzymaj dźwięk kręcenia
      await _audioPlayer.stop();
      
      // Oblicz który segment wygrał na podstawie RZECZYWISTEJ końcowej pozycji koła
      final finalRotation = _wheelAnimation?.value ?? 0;
      final finalAngle = finalRotation % (2 * pi);
      final segmentAngle = 2 * pi / options.length;
      
      // Wskaźnik jest na górze (0 radianów w naszym układzie)
      // Koło obraca się zgodnie z ruchem wskazówek zegara
      final normalizedAngle = (2 * pi - finalAngle) % (2 * pi);
      final selectedIndex = (normalizedAngle / segmentAngle).floor() % options.length;
      
      print('Final angle: $finalAngle (${finalAngle * 180 / pi} degrees)');
      print('Normalized angle: $normalizedAngle (${normalizedAngle * 180 / pi} degrees)');
      print('Selected index: $selectedIndex = ${options[selectedIndex]}');
      
      setState(() {
        _isSpinning = false;
        _selectedOption = options[selectedIndex];
      });
      
      // Opcjonalnie: odtwórz dźwięk zwycięstwa
      try {
        await _audioPlayer.play(AssetSource('sounds/win.mp3'));
      } catch (e) {
        print('Brak dźwięku zwycięstwa');
      }
    });
  }

  void _showEditDialog() {
    final controllers = options.map((opt) => TextEditingController(text: opt)).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'EDYTUJ KOŁO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Liczba opcji:',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: options.length > 2 ? () {
                      setState(() {
                        options.removeLast();
                        controllers.removeLast();
                      });
                      Navigator.pop(context);
                      _showEditDialog();
                    } : null,
                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 32),
                  ),
                  Text(
                    '${options.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: options.length < 32 ? () {
                      setState(() {
                        options.add('${options.length + 1}');
                        controllers.add(TextEditingController(text: '${options.length}'));
                      });
                      Navigator.pop(context);
                      _showEditDialog();
                    } : null,
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controllers[index],
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'Opcja ${index + 1}',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ANULUJ',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (int i = 0; i < options.length; i++) {
                  if (controllers[i].text.isNotEmpty) {
                    options[i] = controllers[i].text;
                  }
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'ZAPISZ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(Colors.purple.shade900, Colors.blue.shade900,
                      (sin(_backgroundController.value * 2 * pi) + 1) / 2)!,
                  Color.lerp(Colors.blue.shade900, Colors.pink.shade900,
                      (cos(_backgroundController.value * 2 * pi) + 1) / 2)!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'KOŁO FORTUNY',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(3.0, 3.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              
              // Koło fortuny
              Stack(
                alignment: Alignment.center,
                children: [
                  // Cień koła
                  Container(
                    width: 310,
                    height: 310,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  
                  // Koło
                  AnimatedBuilder(
                    animation: _wheelController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _wheelAnimation?.value ?? 0,
                        child: CustomPaint(
                          size: const Size(300, 300),
                          painter: WheelPainter(options, colors),
                        ),
                      );
                    },
                  ),
                  
                  // Wskaźnik na górze
                  Positioned(
                    top: 0,
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 60,
                      color: Colors.yellow,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  
                  // Środkowy punkt
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 50),
              
              // Przyciski - responsywne
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  
                  if (isMobile) {
                    // Układ pionowy dla telefonów
                    return Column(
                      children: [
                        // Przycisk START (największy, na górze)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: ElevatedButton(
                            onPressed: _isSpinning ? null : _spinWheel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow.shade700,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                            ),
                            child: Text(_isSpinning ? 'KRĘCI...' : 'START'),
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Przyciski pomocnicze w rzędzie
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.85,
                                    child: AiChatPanel(
                                      lastResult: _selectedOption,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat, size: 18),
                              label: const Text('AI'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 8,
                              ),
                            ),
                            
                            const SizedBox(width: 15),
                            
                            ElevatedButton.icon(
                              onPressed: _isSpinning ? null : _showEditDialog,
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('EDYTUJ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Układ poziomy dla desktop
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Przycisk AI Chat
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SizedBox(
                                height: MediaQuery.of(context).size.height * 0.85,
                                child: AiChatPanel(
                                  lastResult: _selectedOption,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('AI CHAT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                        ),
                        
                        const SizedBox(width: 15),
                        
                        // Przycisk EDYTUJ
                        ElevatedButton.icon(
                          onPressed: _isSpinning ? null : _showEditDialog,
                          icon: const Icon(Icons.edit),
                          label: const Text('EDYTUJ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                        ),
                        
                        const SizedBox(width: 15),
                        
                        // Przycisk START
                        ElevatedButton(
                          onPressed: _isSpinning ? null : _spinWheel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 20,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          child: Text(_isSpinning ? 'KRĘCI SIĘ...' : 'START'),
                        ),
                      ],
                    );
                  }
                },
              ),
              
              const SizedBox(height: 30),
              
              // Wynik
              if (_selectedOption != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Text(
                    'WYNIK: $_selectedOption',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors;

  WheelPainter(this.options, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / options.length;

    for (int i = 0; i < options.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      final startAngle = i * segmentAngle - pi / 2;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Obramowanie segmentu
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Tekst
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.65;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      // Dostosuj rozmiar czcionki w zależności od liczby opcji
      double fontSize;
      if (options.length <= 4) {
        fontSize = 48;
      } else if (options.length <= 8) {
        fontSize = 36;
      } else if (options.length <= 16) {
        fontSize = 24;
      } else {
        fontSize = 16;
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                blurRadius: 5.0,
                color: Colors.black,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
