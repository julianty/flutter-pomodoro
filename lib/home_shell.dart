import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/auth.dart';
import 'package:flutter_pomodoro/timer_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: [UserManagement()],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.timer)),
              Tab(icon: Icon(Icons.dashboard)),
              Tab(icon: Icon(Icons.category)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TimerScreen(),
            Center(child: Text('dashboard')),
            Center(child: Text('categories')),
          ],
        ),
      ),
    );
  }
}
