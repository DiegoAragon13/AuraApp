import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drmarmotino/widgets/settings_cards_widget.dart';
import 'package:drmarmotino/providers/theme_provider.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key});

  @override
  State<Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  bool autoSyncData = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text('Settings', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 30),

              // Sección: Device
              CardsAjustes(
                titulo: 'Device',
                opciones: [
                  const OpcionAjuste(
                    titulo: 'Bluetooth Connection',
                  ),
                  const OpcionAjuste(
                    titulo: 'Scan for Devices',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sección: Appearance
              CardsAjustes(
                titulo: 'Appearance',
                opciones: [
                  OpcionAjuste(
                    titulo: 'Dark Mode',
                    valor: isDarkMode,
                    onChanged: (value) {
                      themeProvider.setThemeMode(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sección: Data
              CardsAjustes(
                titulo: 'Data',
                opciones: [
                  OpcionAjuste(
                    titulo: 'Auto-sync Data',
                    valor: autoSyncData,
                    onChanged: (value) {
                      setState(() {
                        autoSyncData = value;
                      });
                    },
                  ),
                  const OpcionAjuste(
                    titulo: 'Export Format',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botón para borrar todos los datos
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Acción para borrar datos
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Clear All Data'),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Latido Real v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
