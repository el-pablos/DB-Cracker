import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';
import 'flexible_text.dart';
import 'dart:math';

class HackerResultItem extends StatefulWidget {
  final Mahasiswa mahasiswa;
  final VoidCallback onTap;

  const HackerResultItem({
    Key? key,
    required this.mahasiswa,
    required this.onTap,
  }) : super(key: key);

  @override
  _HackerResultItemState createState() => _HackerResultItemState();
}

class _HackerResultItemState extends State<HackerResultItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovering = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _generateHackerCode() {
    const chars = '0123456789ABCDEF';
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtils for responsive design
    ScreenUtils.init(context);
    
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    final double avatarSize = isMobile ? 36.w : 42.w;
    
    return Card(
      margin: ScreenUtils.responsivePadding(
        vertical: isMobile ? 4 : 6, 
        horizontal: isMobile ? 6 : 8
      ),
      color: HackerColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: _isHovering ? HackerColors.primary : HackerColors.accent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) {
          setState(() {
            _isHovering = hovering;
          });
          if (hovering) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        },
        child: Padding(
          padding: ScreenUtils.responsivePadding(all: isMobile ? 8 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: HackerColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: HackerColors.primary,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: FlexibleText(
                        widget.mahasiswa.nama.isNotEmpty
                            ? widget.mahasiswa.nama[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: HackerColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18.adaptiveFont : 20.adaptiveFont,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14.iconSize,
                              color: HackerColors.primary,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: FlexibleText(
                                "SUBJECT: ${widget.mahasiswa.nama.toUpperCase()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.adaptiveFont,
                                  color: HackerColors.primary,
                                  fontFamily: 'Courier',
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.numbers,
                              size: 12.iconSize,
                              color: HackerColors.accent,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: FlexibleText(
                                "ID: ${widget.mahasiswa.nim}",
                                style: TextStyle(
                                  color: HackerColors.accent,
                                  fontSize: 12.adaptiveFont,
                                  fontFamily: 'Courier',
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: ScreenUtils.responsivePadding(all: 4),
                    decoration: BoxDecoration(
                      color: HackerColors.background,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: HackerColors.accent.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: FlexibleText(
                      _generateHackerCode(),
                      style: TextStyle(
                        color: HackerColors.accent.withOpacity(0.8),
                        fontSize: 8.adaptiveFont,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                color: HackerColors.accent,
                height: 20.h,
                thickness: 1,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.school,
                      label: "INSTITUTION",
                      value: widget.mahasiswa.namaPt,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward,
                    color: _isHovering ? HackerColors.primary : HackerColors.accent,
                    size: 16.iconSize,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
_buildInfoRow(
                icon: Icons.book,
                label: "PROGRAM",
                value: widget.mahasiswa.namaProdi,
              ),
              // Tambahkan sumber data jika tersedia
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlexibleText(
                    "SOURCE: " + (widget.mahasiswa.id.contains("=") ? "PDDIKTI" : "MULTI-DB"),
                    style: TextStyle(
                      color: HackerColors.accent.withOpacity(0.7),
                      fontFamily: 'Courier',
                      fontSize: 8.adaptiveFont,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 12.iconSize,
          color: HackerColors.accent,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlexibleText(
                label,
                style: TextStyle(
                  color: HackerColors.text.withOpacity(0.7),
                  fontSize: 10.adaptiveFont,
                  fontFamily: 'Courier',
                ),
              ),
              FlexibleText(
                value,
                style: TextStyle(
                  color: HackerColors.text,
                  fontSize: 12.adaptiveFont,
                  fontFamily: 'Courier',
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}