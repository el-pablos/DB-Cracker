import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

class HackerLoadingIndicator extends StatefulWidget {
  final String message;
  
  const HackerLoadingIndicator({
    Key? key,
    this.message = 'HACKING IN PROGRESS...',
  }) : super(key: key);

  @override
  _HackerLoadingIndicatorState createState() => _HackerLoadingIndicatorState();
}

class _HackerLoadingIndicatorState extends State<HackerLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  List<String> _hexLines = [];
  int _currentDots = 0;
  late final int _totalHexLines = 8;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat();
    
    _controller.addListener(_updateDots);
    _generateHexCode();
  }
  
  @override
  void dispose() {
    _controller.removeListener(_updateDots);
    _controller.dispose();
    super.dispose();
  }
  
  void _updateDots() {
    if (_controller.value < 0.25) {
      if (_currentDots != 1) {
        setState(() {
          _currentDots = 1;
          _generateHexCode();
        });
      }
    } else if (_controller.value < 0.5) {
      if (_currentDots != 2) {
        setState(() {
          _currentDots = 2;
          _generateHexCode();
        });
      }
    } else if (_controller.value < 0.75) {
      if (_currentDots != 3) {
        setState(() {
          _currentDots = 3;
          _generateHexCode();
        });
      }
    } else {
      if (_currentDots != 0) {
        setState(() {
          _currentDots = 0;
          _generateHexCode();
        });
      }
    }
  }
  
  void _generateHexCode() {
    final hexChars = '0123456789ABCDEF';
    _hexLines = List.generate(_totalHexLines, (_) {
      final length = _random.nextInt(32) + 16;
      return List.generate(length, (_) {
        return hexChars[_random.nextInt(hexChars.length)];
      }).join('');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final dots = '.' * _currentDots;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HackerColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: HackerColors.accent),
              boxShadow: [
                BoxShadow(
                  color: HackerColors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: HackerColors.primary,
                      width: 2,
                    ),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(HackerColors.primary),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${widget.message}$dots",
                  style: const TextStyle(
                    color: HackerColors.primary,
                    fontSize: 16,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 280,
                  height: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HackerColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: HackerColors.accent.withOpacity(0.5)),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _hexLines.length,
                    itemBuilder: (context, index) {
                      final opacity = 1.0 - (index / _totalHexLines * 0.7);
                      return Text(
                        _hexLines[index],
                        style: TextStyle(
                          color: HackerColors.accent.withOpacity(opacity),
                          fontSize: 10,
                          fontFamily: 'Courier',
                          height: 1.2,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}