import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';

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
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    
    // Hitung durasi berdasarkan panjang teks, tapi dengan batasan maksimum
    final int textLength = widget.text.length;
    final int maxDuration = 2000; // ms
    final int baseDuration = 500; // ms
    final int calculatedDuration = baseDuration + (textLength * 20);
    final int safeDuration = calculatedDuration > maxDuration ? maxDuration : calculatedDuration;
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: safeDuration),
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
    
    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isComplete = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan ScreenUtils diinisialisasi
    if (ScreenUtils.screenWidth == 0) {
      ScreenUtils.init(context);
    }
    
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
        // Cegah overflow dengan substring yang aman
        final int safeEnd = _textLengthAnimation.value < widget.text.length 
            ? _textLengthAnimation.value 
            : widget.text.length;
            
        final String displayedText = widget.text.substring(0, safeEnd);
        
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5, // Batasi jumlah baris untuk mencegah overflow
                  ),
                ),
                if (!_isComplete && _textLengthAnimation.value < widget.text.length)
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