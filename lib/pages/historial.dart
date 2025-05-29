import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class historial extends StatefulWidget {
  const historial({super.key});

  @override
  State<historial> createState() => _historialState();
}

class _historialState extends State<historial> {
  bool isLoading = true;
  List<HealthData> heartRateData = [];
  List<HealthData> oxygenData = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromFirebase();
  }

  void _loadDataFromFirebase() async {
    try {
      // Obtenemos las últimas 50 mediciones
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('mediciones')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      // Agrupa los datos por día
      Map<String, List<double>> hrByDay = {};
      Map<String, List<double>> spo2ByDay = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('timestamp') &&
            data.containsKey('heart_rate_avg') &&
            data.containsKey('spo2_avg')) {

          Timestamp timestamp = data['timestamp'];
          DateTime date = timestamp.toDate();

          // Formateamos el día de la semana en español
          String dayKey = _getDayOfWeekInSpanish(date);

          // Añadimos los datos a las listas correspondientes
          if (!hrByDay.containsKey(dayKey)) {
            hrByDay[dayKey] = [];
          }
          if (!spo2ByDay.containsKey(dayKey)) {
            spo2ByDay[dayKey] = [];
          }

          hrByDay[dayKey]!.add(data['heart_rate_avg'].toDouble());
          spo2ByDay[dayKey]!.add(data['spo2_avg'].toDouble());
        }
      }

      // Calculamos los promedios para cada día
      List<HealthData> hrData = [];
      List<HealthData> spo2Data = [];

      // Definimos el orden de los días de la semana
      List<String> daysOrder = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

      // Iteramos por los días en orden
      for (String day in daysOrder) {
        if (hrByDay.containsKey(day) && hrByDay[day]!.isNotEmpty) {
          double avgHr = hrByDay[day]!.reduce((a, b) => a + b) / hrByDay[day]!.length;
          hrData.add(HealthData(day, avgHr));
        } else {
          // Añadimos un valor nulo para mantener la continuidad del gráfico
          hrData.add(HealthData(day, 0));
        }

        if (spo2ByDay.containsKey(day) && spo2ByDay[day]!.isNotEmpty) {
          double avgSpo2 = spo2ByDay[day]!.reduce((a, b) => a + b) / spo2ByDay[day]!.length;
          spo2Data.add(HealthData(day, avgSpo2));
        } else {
          // Añadimos un valor nulo para mantener la continuidad del gráfico
          spo2Data.add(HealthData(day, 0));
        }
      }

      // Actualizamos el estado
      if (mounted) {
        setState(() {
          heartRateData = hrData;
          oxygenData = spo2Data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Función para convertir el día de la semana a formato español abreviado
  String _getDayOfWeekInSpanish(DateTime date) {
    switch (DateFormat('E').format(date)) {
      case 'Mon':
        return 'Lun';
      case 'Tue':
        return 'Mar';
      case 'Wed':
        return 'Mié';
      case 'Thu':
        return 'Jue';
      case 'Fri':
        return 'Vie';
      case 'Sat':
        return 'Sáb';
      case 'Sun':
        return 'Dom';
      default:
        return DateFormat('E').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y subtítulo
              Text(
                'Análisis',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Historial de signos vitales',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.indigo[700],
                ),
              ),
              const SizedBox(height: 24),

              // Tarjeta de gráfico
              Expanded(
                child: Container(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del gráfico
                      Text(
                        'Tendencias semanales',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gráfico
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildCharts(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      children: [
        // Gráfico de ritmo cardíaco
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'Ritmo Cardíaco (latidos/min)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: const TextStyle(color: Color(0xFF68737d)),
                      axisLine: const AxisLine(width: 1),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 40,
                      maximum: 120,
                      interval: 20,
                      labelStyle: const TextStyle(color: Color(0xFF68737d)),
                      axisLine: const AxisLine(width: 1),
                    ),
                    series: <CartesianSeries<HealthData, String>>[
                      LineSeries<HealthData, String>(
                        dataSource: heartRateData,
                        xValueMapper: (HealthData data, _) => data.day,
                        yValueMapper: (HealthData data, _) => data.value,
                        name: 'BPM',
                        color: Colors.red[700],
                        width: 3,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.circle,
                          height: 8,
                          width: 8,
                        ),
                        emptyPointSettings: EmptyPointSettings(
                          mode: EmptyPointMode.drop,
                        ),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Gráfico de oxigenación
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'Oxigenación (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: const TextStyle(color: Color(0xFF68737d)),
                      axisLine: const AxisLine(width: 1),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 85,
                      maximum: 100,
                      interval: 5,
                      labelStyle: const TextStyle(color: Color(0xFF68737d)),
                      axisLine: const AxisLine(width: 1),
                    ),
                    series: <CartesianSeries<HealthData, String>>[
                      LineSeries<HealthData, String>(
                        dataSource: oxygenData,
                        xValueMapper: (HealthData data, _) => data.day,
                        yValueMapper: (HealthData data, _) => data.value,
                        name: 'SpO2',
                        color: Colors.blue[700],
                        width: 3,
                        markerSettings: const MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.circle,
                          height: 8,
                          width: 8,
                        ),
                        emptyPointSettings: EmptyPointSettings(
                          mode: EmptyPointMode.drop,
                        ),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Modelo de datos para las métricas de salud
class HealthData {
  final String day;
  final double value;

  HealthData(this.day, this.value);
}