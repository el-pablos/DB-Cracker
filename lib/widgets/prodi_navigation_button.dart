import 'package:flutter/material.dart';
import '../models/prodi.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';
import 'flexible_text.dart';

/// Widget tombol untuk navigasi ke layar detail program studi
class ProdiNavigationButton extends StatelessWidget {
  final Prodi prodi;
  final bool isCompact;
  
  const ProdiNavigationButton({
    Key? key,
    required this.prodi,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    return InkWell(
      onTap: () {
        // Gunakan named routes untuk navigasi
        Navigator.pushNamed(
          context,
          '/prodi/detail/${prodi.id}',
          arguments: {
            'prodiName': prodi.nama,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: isCompact ? 0.0 : 8.0,
        ),
        padding: EdgeInsets.all(isCompact ? 8.0 : 12.0),
        decoration: BoxDecoration(
          color: HackerColors.surface,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: HackerColors.accent, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: HackerColors.primary.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.school,
              color: HackerColors.primary,
              size: isCompact ? 16.0 : 20.0,
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FlexibleText(
                    prodi.nama,
                    style: TextStyle(
                      color: HackerColors.primary,
                      fontFamily: 'Courier',
                      fontSize: isCompact ? 12.0 : 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                  ),
                  if (!isCompact) ...[
                    SizedBox(height: 4.0),
                    FlexibleText(
                      '${prodi.jenjang} | ${prodi.pt}',
                      style: TextStyle(
                        color: HackerColors.text.withOpacity(0.8),
                        fontFamily: 'Courier',
                        fontSize: 12.0,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: HackerColors.accent,
              size: isCompact ? 14.0 : 16.0,
            ),
          ],
        ),
      ),
    );
  }
}