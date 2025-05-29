import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomeCardWidget extends StatefulWidget {
  const WelcomeCardWidget({Key? key}) : super(key: key);

  @override
  State<WelcomeCardWidget> createState() => _WelcomeCardWidgetState();
}

class _WelcomeCardWidgetState extends State<WelcomeCardWidget> {
  int heartRate = 0;  // Valor por defecto
  int oxygenLevel = 0; // Valor por defecto
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Iniciar la escucha de datos desde Firebase
    _getLatestVitalSigns();
  }

  void _getLatestVitalSigns() {
    // Referencia a la colección de mediciones
    FirebaseFirestore.instance
        .collection('mediciones')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var latestData = snapshot.docs.first.data();

        setState(() {
          heartRate = latestData['heart_rate_avg'].round();
          oxygenLevel = latestData['spo2_avg'].round();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error al obtener datos: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Heart Rate Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8.0),
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pulso\ncardíaco',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  const SizedBox(height: 10),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                    '$heartRate',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Oxygen Level Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8.0),
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oxigenación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  const SizedBox(height: 10),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$oxygenLevel',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                      Text(
                        '%',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SpO2',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}