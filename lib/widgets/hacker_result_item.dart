import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../utils/constants.dart';

class HackerResultItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isEven = mahasiswa.hashCode % 2 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isEven ? CtOSColors.primary : CtOSColors.secondary,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isEven ? CtOSColors.primary : CtOSColors.secondary)
                .withValues(alpha: 0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: CtOSColors.background,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isEven ? CtOSColors.primary : CtOSColors.secondary,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Text(
                  mahasiswa.nama.isNotEmpty
                      ? mahasiswa.nama[0].toUpperCase()
                      : 'M',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: isEven ? CtOSColors.primary : CtOSColors.secondary,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Mahasiswa
                  Text(
                    mahasiswa.nama,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: CtOSColors.textPrimary,
                      fontFamily: 'Courier',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),

                  // NIM
                  if (mahasiswa.nim.isNotEmpty)
                    Text(
                      'NIM: ${mahasiswa.nim}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color:
                            isEven ? CtOSColors.primary : CtOSColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Courier',
                      ),
                    ),
                  const SizedBox(height: 4.0),

                  // Program Studi
                  Text(
                    mahasiswa.namaProdi,
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: CtOSColors.textAccent,
                      fontFamily: 'Courier',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),

                  // Perguruan Tinggi
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color:
                          (isEven ? CtOSColors.primary : CtOSColors.secondary)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: (isEven
                                ? CtOSColors.primary
                                : CtOSColors.secondary)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      mahasiswa.namaPt,
                      style: TextStyle(
                        fontSize: 11.0,
                        color:
                            isEven ? CtOSColors.primary : CtOSColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Courier',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: CtOSColors.textAccent,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}
