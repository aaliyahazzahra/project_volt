import 'package:flutter/material.dart';

class BottomNavKelas extends StatelessWidget {
  const BottomNavKelas({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(items: 3): BottomBarBubble(
    selectedIndex: _index,
    items: [
        BottomBarItem(
          iconBuilder: (color) => Image.asset('assets/ic_alarm.png', color: color, height: 30, width: 30)),
        BottomBarItem(
          iconBuilder: (color) => Image.asset('assets/ic_bill.png', color: color, height: 30, width: 30)),
        BottomBarItem(
          iconBuilder: (color) => Image.asset('assets/ic_box.png', color: color, height: 30, width: 30)),
    ],
    onSelect: (index) {
      // implement your select function here
    },
),
  }
}
