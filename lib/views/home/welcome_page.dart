import 'package:flutter/material.dart';
import 'home.dart';
import 'info.dart';
import 'agenda.dart';
import 'galery.dart';

class WelcomeScreen extends StatefulWidget {
  final String userName;

  const WelcomeScreen({super.key, required this.userName});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(userName: widget.userName),
      InfoScreen(),
      AgendaScreen(),
      GaleriScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.grey[800]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Button
            buildNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              isSelected: _selectedIndex == 0,
              index: 0,
            ),
            // Info Button
            buildNavItem(
              icon: Icons.info_outline,
              label: 'Info',
              isSelected: _selectedIndex == 1,
              index: 1,
            ),
            // Agenda Button
            buildNavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Agenda',
              isSelected: _selectedIndex == 2,
              index: 2,
            ),
            // Gallery Button
            buildNavItem(
              icon: Icons.photo_outlined,
              label: 'Gallery',
              isSelected: _selectedIndex == 3,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each navigation item
  Widget buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: isSelected
                ? Colors.white
                : Colors.white60, // White for selected, light gray for inactive
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
