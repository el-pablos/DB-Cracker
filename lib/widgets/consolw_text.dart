import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ConsoleText extends StatefulWidget {
  final String text;
  final bool isInput;
  final bool isError;
  final bool isSuccess;

  const ConsoleText({
    Key? key,
    required this.text,
    this.isInput = false,
    this.isError = false,
    this.isSuccess = false,
  }) : super(key: key);

  @override
  _ConsoleTextState createState() => _ConsoleTextState();
}

class _ConsoleTextState extends State<ConsoleText> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<int> _textLengthAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 20),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    ));
    
    _textLengthAnimation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = HackerColors.text;
    
    if (widget.isError) {
      textColor = HackerColors.error;
    } else if (widget.isSuccess) {
      textColor = HackerColors.success;
    } else if (widget.isInput) {
      textColor = HackerColors.primary;
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final displayedText = widget.text.substring(
          0, 
          _textLengthAnimation.value,
        );
        
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isInput) 
                  const Text(
                    ">",
                    style: TextStyle(
                      color: HackerColors.primary,
                      fontFamily: 'Courier',
                      fontSize: 14,
                    ),
                  ),
                if (widget.isInput) 
                  const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayedText,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'Courier',
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                if (_textLengthAnimation.value < widget.text.length)
                  const Text(
                    "█",
                    style: TextStyle(
                      color: HackerColors.primary,
                      fontFamily: 'Courier',
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}