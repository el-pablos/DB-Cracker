import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../utils/constants.dart';
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
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;
    final double avatarSize = isMobile ? 36 : 42;
    
    return Card(
      margin: EdgeInsets.symmetric(
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
                        color: HackerColors.primary,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.mahasiswa.nama.isNotEmpty
                            ? widget.mahasiswa.nama[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: HackerColors.primary,
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
                            const Icon(
                              Icons.person,
                              size: 14,
                              color: HackerColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "SUBJECT: ${widget.mahasiswa.nama.toUpperCase()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: HackerColors.primary,
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
                            const Icon(
                              Icons.numbers,
                              size: 12,
                              color: HackerColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "ID: ${widget.mahasiswa.nim}",
                                style: const TextStyle(
                                  color: HackerColors.accent,
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
                        color: HackerColors.accent.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _generateHackerCode(),
                      style: TextStyle(
                        color: HackerColors.accent.withOpacity(0.8),
                        fontSize: 8,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: HackerColors.accent,
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: _isHovering ? HackerColors.primary : HackerColors.accent,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.book,
                label: "PROGRAM",
                value: widget.mahasiswa.namaProdi,
              ),
              // Tambahkan sumber data jika tersedia
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "SOURCE: " + (widget.mahasiswa.id.contains("=") ? "PDDIKTI" : "MULTI-DB"),
                    style: TextStyle(
                      color: HackerColors.accent.withOpacity(0.7),
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
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 12,
          color: HackerColors.accent,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: HackerColors.text.withOpacity(0.7),
                  fontSize: 10,
                  fontFamily: 'Courier',
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: HackerColors.text,
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}