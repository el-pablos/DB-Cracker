import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../utils/constants.dart';
import 'dart:math';

class HackerResultItem extends StatefulWidget {
  final Mahasiswa mahasiswa;
  final VoidCallback onTap;
  final bool isFiltered;

  const HackerResultItem({
    Key? key,
    required this.mahasiswa,
    required this.onTap,
    this.isFiltered = false,
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
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;
    final double avatarSize = isMobile ? 36 : 42;
    
    // Ubah warna berdasarkan status filter
    final Color primaryColor = widget.isFiltered 
        ? HackerColors.warning 
        : HackerColors.primary;
    
    final Color accentColor = widget.isFiltered 
        ? HackerColors.warning.withOpacity(0.8) 
        : HackerColors.accent;
    
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: isMobile ? 4 : 6, 
        horizontal: isMobile ? 6 : 8
      ),
      color: HackerColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: _isHovering ? primaryColor : accentColor,
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
          padding: const EdgeInsets.all(12.0),
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
                        color: primaryColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.mahasiswa.nama.isNotEmpty
                            ? widget.mahasiswa.nama[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "SUBJECT: ${widget.mahasiswa.nama.toUpperCase()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: primaryColor,
                                  fontFamily: 'Courier',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.numbers,
                              size: 12,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "ID: ${widget.mahasiswa.nim}",
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontFamily: 'Courier',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: HackerColors.background,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: accentColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _generateHackerCode(),
                      style: TextStyle(
                        color: accentColor.withOpacity(0.8),
                        fontSize: 8,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                color: accentColor,
                height: 20,
                thickness: 1,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.school,
                      label: "INSTITUTION",
                      value: widget.mahasiswa.namaPt,
                      labelColor: accentColor,
                      valueColor: widget.isFiltered 
                          ? HackerColors.warning 
                          : HackerColors.text,
                      highlight: widget.isFiltered,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: _isHovering ? primaryColor : accentColor,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.book,
                label: "PROGRAM",
                value: widget.mahasiswa.namaProdi,
                labelColor: accentColor,
                valueColor: HackerColors.text,
              ),
              // Tambahkan sumber data jika tersedia
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "SOURCE: " + (widget.mahasiswa.id.contains("=") ? "PDDIKTI" : "MULTI-DB"),
                    style: TextStyle(
                      color: accentColor.withOpacity(0.7),
                      fontFamily: 'Courier',
                      fontSize: 8,
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
    Color? labelColor,
    Color? valueColor,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 12,
          color: labelColor ?? HackerColors.accent,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: (labelColor ?? HackerColors.accent).withOpacity(0.7),
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
              Container(
                decoration: highlight ? BoxDecoration(
                  color: HackerColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: HackerColors.warning.withOpacity(0.3),
                    width: 1,
                  ),
                ) : null,
                padding: highlight ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1) : null,
                child: Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? HackerColors.text,
                    fontSize: 12,
                    fontFamily: 'Courier',
                    fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}