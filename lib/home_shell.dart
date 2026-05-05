import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/auth.dart';
import 'package:flutter_pomodoro/category_screen.dart';
import 'package:flutter_pomodoro/dashboard_screen.dart';
import 'package:flutter_pomodoro/timer_controller.dart';
import 'package:flutter_pomodoro/timer_screen.dart';

class HomeShell extends StatelessWidget {
  HomeShell({super.key});

  final TimerController timerController = TimerController();

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
        body: Column(
          children: [
            // MiniTimer(controller: timerController),
            Expanded(
              child: TabBarView(
                children: [
                  TimerScreen(controller: timerController),
                  DashboardScreen(),
                  CategoryScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
