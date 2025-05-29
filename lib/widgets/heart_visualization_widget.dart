import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'dart:math' as math;

class UnityLauncherWidget extends StatefulWidget {
  const UnityLauncherWidget({Key? key}) : super(key: key);

  @override
  State<UnityLauncherWidget> createState() => _UnityLauncherWidgetState();
}

class _UnityLauncherWidgetState extends State<UnityLauncherWidget>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _breathingController;
  bool _isMeditationDialogOpen = false;
  // Número de corazones activos (rachas)
  int _activeHearts = 2;
  final int _totalHearts = 5;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  Future<void> _launchUnityApp() async {
    const packageName = 'com.DiegoAragon.corazon2';
    bool isInstalled = await DeviceApps.isAppInstalled(packageName);
    if (isInstalled) {
      await DeviceApps.openApp(packageName);
    } else {
      throw Exception('La app Unity no está instalada');
    }
  }

  Future<void> _onTapLaunch() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      await _launchUnityApp();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir la app: $e'),
            backgroundColor: Colors.deepPurple,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openMeditationDialog() {
    setState(() {
      _isMeditationDialogOpen = true;

      // Reinicia la animación para comenzar desde el estado "pequeño"
      _breathingController.reset();
      _breathingController.repeat(reverse: true);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Obtener tamaño de pantalla para cálculos de tamaño adaptable
        final Size screenSize = MediaQuery.of(context).size;
        final double maxCircleSize = screenSize.width < screenSize.height
            ? screenSize.width * 0.6 // En pantallas estrechas
            : screenSize.height * 0.5; // En pantallas anchas

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 300,
            // Usar ConstrainedBox para limitar altura basada en tamaño de pantalla
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra superior con corazones
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E57C2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sesión de Meditación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Zona de Meditación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),

                // Contenedor para la animación, con restricciones de tamaño
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calcular tamaño máximo disponible, manteniendo un aspecto cuadrado
                      final double maxSize = math.min(constraints.maxWidth, constraints.maxHeight);
                      // Calcular tamaño base del círculo principal (70% del espacio disponible)
                      final double baseCircleSize = maxSize * 0.7;
                      // Calcular tamaño máximo para la expansión (no exceder 90% del espacio)
                      final double maxCircleExpansion = maxSize * 0.9;

                      return SizedBox(
                        width: maxSize,
                        height: maxSize,
                        child: AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            // Determinar fase de respiración
                            final isInhaling = _breathingController.value <= 0.5;
                            final adjustedValue = isInhaling
                                ? _breathingController.value * 2  // 0 -> 1 durante inhalación
                                : (1 - (_breathingController.value - 0.5) * 2); // 1 -> 0 durante exhalación

                            // Calcular tamaño actual del círculo principal
                            final double currentCircleSize = baseCircleSize +
                                (maxCircleExpansion - baseCircleSize) * adjustedValue;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ondas externas pulsantes (ajustadas para no exceder el espacio)
                                ...List.generate(3, (index) {
                                  final delay = index * 0.2;
                                  final waveAnimValue = (adjustedValue - delay).clamp(0.0, 1.0);
                                  // Tamaño máximo de onda adaptado al espacio disponible
                                  final maxWaveSize = baseCircleSize * 1.15;
                                  final waveSize = baseCircleSize + (maxWaveSize - baseCircleSize) * waveAnimValue;

                                  return Opacity(
                                    opacity: (0.3 - (index * 0.1)) * waveAnimValue,
                                    child: Container(
                                      width: waveSize,
                                      height: waveSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                        border: Border.all(
                                          color: Color.lerp(
                                            const Color(0xFF9575CD),
                                            const Color(0xFF7E57C2),
                                            waveAnimValue,
                                          )!,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                // Círculo principal animado - tamaño controlado
                                Container(
                                  width: currentCircleSize,
                                  height: currentCircleSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Color.lerp(
                                          const Color(0xFFD1C4E9),
                                          const Color(0xFF7E57C2),
                                          adjustedValue,
                                        )!,
                                        Color.lerp(
                                          const Color(0xFF9575CD),
                                          const Color(0xFF5E35B1),
                                          adjustedValue,
                                        )!,
                                      ],
                                      center: Alignment.center,
                                      focal: Alignment.center,
                                      radius: 0.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF7E57C2).withOpacity(0.3 * adjustedValue),
                                        blurRadius: 10 + 10 * adjustedValue,
                                        spreadRadius: 5 * adjustedValue,
                                      ),
                                    ],
                                  ),
                                ),

                                // Círculo interno pulsante - tamaño proporcional al círculo principal
                                Container(
                                  width: currentCircleSize * 0.4, // 40% del tamaño del círculo principal
                                  height: currentCircleSize * 0.4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),

                                // Partículas de luz (pequeños círculos) - órbita contenida
                                ...List.generate(5, (index) {
                                  final angle = index * (math.pi * 2 / 5);
                                  // Radio de órbita proporcional al tamaño del círculo principal
                                  final radius = currentCircleSize * 0.45;
                                  final x = radius * math.cos(angle + _breathingController.value * math.pi);
                                  final y = radius * math.sin(angle + _breathingController.value * math.pi);

                                  return Transform.translate(
                                    offset: Offset(x, y),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  );
                                }),

                                // Texto guía de respiración con animación
                                AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Text(
                                    _breathingController.value <= 0.5
                                        ? 'Inhala...'
                                        : 'Exhala...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 3,
                                          offset: const Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo[700],
                      ),
                      children: const [
                        TextSpan(
                          text: 'Sigue el ritmo del círculo\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Inhala cuando se expande, exhala cuando se contrae',
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isMeditationDialogOpen = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: const Color(0xFF7E57C2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Incrementar corazón como recompensa por completar la sesión
                          Navigator.of(context).pop();
                          setState(() {
                            _isMeditationDialogOpen = false;
                            // Incrementar corazones si no está lleno
                            if (_activeHearts < _totalHearts) {
                              _activeHearts++;
                            }
                            // Mostrar mensaje de felicitación
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Felicidades! Has completado una sesión de meditación'),
                                backgroundColor: Color(0xFF7E57C2),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Completar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isMeditationDialogOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Changed to min to prevent overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra superior con corazones tipo "racha"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF7E57C2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Texto de racha - con Flexible para permitir que se comprima si es necesario
                const Flexible(
                  child: Text(
                    'Racha de meditación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // Espacio mínimo entre texto y corazones
                // Corazones en un contenedor con scroll horizontal si son demasiados
                Container(
                  constraints: const BoxConstraints(maxWidth: 150), // Limitar ancho máximo
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Para que tome el tamaño mínimo necesario
                    children: List.generate(_totalHearts, (index) {
                      final bool isActive = index < _activeHearts;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2), // Reducir padding de 3 a 2
                        child: Icon(
                          Icons.favorite,
                          color: isActive ? Colors.red : Colors.white.withOpacity(0.3),
                          size: 22, // Reducir tamaño de 24 a 22
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Título
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 16), // Reduced padding
            child: Text(
              'Visualización 3D',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          // Área táctil para lanzar Unity
          GestureDetector(
            onTap: _isLoading ? null : _onTapLaunch,
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 20), // Reduced bottom margin
              height: 250, // Reduced height from 300 to 250
              decoration: BoxDecoration(
                color: const Color(0xFFE8E3F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _isLoading
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Abriendo Visualización 3D...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.view_in_ar,
                      size: 64,
                      color: Colors.indigo[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Toca para abrir visualización 3D',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Nuevo botón de meditación
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), // Reduced bottom padding
            child: ElevatedButton(
              onPressed: _isMeditationDialogOpen ? null : _openMeditationDialog,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: const Color(0xFF7E57C2),
                minimumSize: const Size(double.infinity, 50), // Reduced height from 56 to 50
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.self_improvement,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ejercicio de Respiración',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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