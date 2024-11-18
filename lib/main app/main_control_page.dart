import 'package:flutter/material.dart';
import 'package:iot_project/main%20app/home/home.dart';
import 'package:iot_project/main%20app/setting/setting.dart';

class MainControlPage extends StatefulWidget {
  const MainControlPage({super.key});

  @override
  State<MainControlPage> createState() => _MainControlPageState();
}

class _MainControlPageState extends State<MainControlPage> {
  int _selectedTab = 0;

  static final List<Widget> _widgetList = <Widget>[
    const Home(),
    const Setting(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: IndexedStack(
        index: _selectedTab,
        children: _widgetList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Thêm dòng này
        currentIndex: _selectedTab,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',

          ),
        ],
        selectedItemColor: const Color(0xff000000),
        unselectedItemColor: const Color(0xFF9ba1a8),
      ),
    );
  }
}
