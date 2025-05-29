import 'package:flutter/material.dart';
import 'package:drmarmotino/pages/home.dart';
import 'package:drmarmotino/pages/historial.dart';
import 'package:drmarmotino/pages/educacion.dart';
import 'package:drmarmotino/pages/ajustes.dart';
import 'package:drmarmotino/pages/homehome.dart';


import 'package:drmarmotino/widgets/app_bar_widget.dart';
import 'package:drmarmotino/widgets/bottom_bar_widget.dart';




// Main container que usa BottomBarWidget
class navigationForPages extends StatefulWidget {
  const navigationForPages({super.key});

  @override
  State<navigationForPages> createState() => _navigationForPagesState();
}

class _navigationForPagesState extends State<navigationForPages> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeHome(),
    const HomeScreen(),
    const historial(),
    const educacion(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // appBar: const CustomAppBar(notificationCount: 3),
      
      // 👇 Aquí cambias body por IndexedStack
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: BottomBarWidget(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
