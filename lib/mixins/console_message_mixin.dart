import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Mixin untuk shared console message logic yang dipakai di semua screen
/// Menggantikan duplikasi _addConsoleMessageWithDelay di 6 screens
mixin ConsoleMessageMixin<T extends StatefulWidget> on State<T> {
  final List<String> consoleMessages = [];
  final List<Timer> activeTimers = [];
  late final bool statusDotIsGreen;

  /// Inisialisasi mixin — panggil di initState()
  void initConsoleMessageMixin() {
    statusDotIsGreen = Random().nextBool();
  }

  /// Tambah console message dengan delay
  void addConsoleMessage(String message, int delayMs) {
    final timer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted) {
        setState(() {
          consoleMessages.add(message);
        });
      }
    });
    activeTimers.add(timer);
  }

  /// Cancel semua active timers — panggil di dispose()
  void disposeConsoleTimers() {
    for (final timer in activeTimers) {
      timer.cancel();
    }
    activeTimers.clear();
  }

  /// Generate random hex value untuk visual effect
  String getRandomHexValue(int length) {
    const chars = '0123456789ABCDEF';
    final random = Random();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
