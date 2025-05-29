import 'package:flutter/material.dart';

class educacion extends StatelessWidget {
  const educacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E9), // Color lila claro como en la imagen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Título principal
              const Text(
                'Educación',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF332868), // Color morado oscuro para el título
                ),
              ),
              const SizedBox(height: 8),
              // Subtítulo
              const Text(
                'Aprende sobre tu bienestar',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF6E5C9C), // Color morado medio para el subtítulo
                ),
              ),
              const SizedBox(height: 24),
              // Lista de temas educativos
              Expanded(
                child: ListView(
                  children: const [
                    EducationCard(
                      icon: Icons.favorite,
                      title: 'Importancia del monitoreo cardíaco',
                      description: 'Monitorear tu ritmo cardíaco te ayuda a entender cómo responde tu cuerpo al estrés, ejercicio y descanso.',
                    ),
                    SizedBox(height: 16),
                    EducationCard(
                      icon: Icons.psychology,
                      title: 'Salud mental y signos vitales',
                      description: 'Existe una fuerte conexión entre tu salud mental y tus signos vitales. El estrés puede afectar tu presión arterial y ritmo cardíaco.',
                    ),
                    SizedBox(height: 16),
                    EducationCard(
                      icon: Icons.air,
                      title: 'Oxigenación y claridad mental',
                      description: 'Niveles óptimos de oxígeno en sangre mejoran la función cerebral y promueven la claridad mental.',
                    ),
                    SizedBox(height: 16),
                    EducationCard(
                      icon: Icons.lightbulb_outline,
                      title: 'Técnicas de respiración',
                      description: 'Practicar técnicas de respiración profunda puede ayudar a regular tu ritmo cardíaco y reducir la ansiedad.',
                    ),
                    SizedBox(height: 16),
                    EducationCard(
                      icon: Icons.nightlight_round,
                      title: 'Importancia del sueño',
                      description: 'El sueño de calidad es esencial para la recuperación física y mental, afectando positivamente tus signos vitales.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EducationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EducationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEBE3F5), // Fondo lila claro para los iconos
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF332868), // Color morado oscuro para los iconos
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF332868), // Color morado oscuro para los títulos
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6E5C9C), // Color morado medio para las descripciones
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}