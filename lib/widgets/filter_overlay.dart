import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

/// Widget overlay untuk menampilkan animasi proses filtering
class FilterOverlay extends StatefulWidget {
  final String message;

  const FilterOverlay({
    Key? key,
    this.message = 'MENERAPKAN FILTER...',
  }) : super(key: key);

  @override
  _FilterOverlayState createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  List<String> _hexLines = [];
  int _currentDots = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
    if (_controller.value < 0.33) {
      if (_currentDots != 1) {
        setState(() {
          _currentDots = 1;
          _generateHexCode();
        });
      }
    } else if (_controller.value < 0.66) {
      if (_currentDots != 2) {
        setState(() {
          _currentDots = 2;
          _generateHexCode();
        });
      }
    } else {
      if (_currentDots != 3) {
        setState(() {
          _currentDots = 3;
          _generateHexCode();
        });
      }
    }
  }
  
  void _generateHexCode() {
    final hexChars = '0123456789ABCDEF';
    _hexLines = List.generate(4, (_) {
      final length = _random.nextInt(16) + 8;
      return List.generate(length, (_) {
        return hexChars[_random.nextInt(hexChars.length)];
      }).join('');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final dots = '.' * _currentDots;
    
    return Container(
      color: HackerColors.background.withOpacity(0.85),
      child: Center(
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HackerColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: HackerColors.warning),
            boxShadow: [
              BoxShadow(
                color: HackerColors.warning.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HackerColors.warning,
                    width: 2,
                  ),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(HackerColors.warning),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${widget.message}$dots",
                style: const TextStyle(
                  color: HackerColors.warning,
                  fontSize: 14,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                width: 160,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: HackerColors.background,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: HackerColors.warning.withOpacity(0.5)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _hexLines.map((line) => Text(
                    line,
                    style: TextStyle(
                      color: HackerColors.warning.withOpacity(0.7),
                      fontSize: 8,
                      fontFamily: 'Courier',
                      height: 1.2,
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}