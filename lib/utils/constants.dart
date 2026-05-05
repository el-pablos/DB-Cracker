import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'DB Cracker';
  static const String appVersion = 'v2.0';
  static const String homeTitle = 'DB Cracker';

  // Search
  static const String searchHint = 'Cari mahasiswa, dosen, atau prodi...';
  static const String filterHint = 'Filter universitas...';
  static const String emptySearchPrompt = 'Masukkan nama untuk memulai pencarian';
  static const String scanningMessage = 'Mencari data...';
  static const String noResultsFound = 'Tidak ditemukan hasil untuk';
  static const String noFilterResults = 'Tidak ada hasil untuk filter ini';
  static const String noFilterResultsFound = 'Tidak ada hasil untuk filter ini';
  static const String pleaseEnterSearchTerm = 'Masukkan kata kunci pencarian';
  static const String errorSearching = 'Gagal mencari:';
  static const String clearFilter = 'Hapus Filter';

  // Details
  static const String personalInfoTitle = 'Data Pribadi';
  static const String academicInfoTitle = 'Data Akademik';
  static const String errorLoadingData = 'Gagal memuat data:';
  static const String noDataAvailable = 'Data tidak tersedia';
  static const String retry = 'Coba Lagi';

  // Student Info Labels
  static const String name = 'Nama';
  static const String studentId = 'NIM';
  static const String gender = 'Jenis Kelamin';
  static const String entryYear = 'Tahun Masuk';
  static const String registrationType = 'Jenis Pendaftaran';
  static const String currentStatus = 'Status';
  static const String university = 'Perguruan Tinggi';
  static const String universityCode = 'Kode PT';
  static const String studyProgram = 'Program Studi';
  static const String studyProgramCode = 'Kode Prodi';
  static const String educationLevel = 'Jenjang';

  // Filter
  static const String filterTitle = 'Filter Universitas';
  static const String selectUniversity = 'Pilih Universitas';
  static const String filterCleared = 'Filter dihapus';
  static const String filterResults = 'Hasil Filter';
  static const String reset = 'Reset';
}

/// LEGACY: CtOSColors kept temporarily for backward compatibility
/// during migration. Screens being migrated should use AppColors instead.
/// TODO: Remove after all screens migrated to Neo-Violet theme.
class CtOSColors {
  CtOSColors._();

  // Primary ctOS colors — DEPRECATED, use AppColors.primary
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFE2E8F0);
  static const Color warning = Color(0xFFF59E0B);

  // Background colors — DEPRECATED, use AppColors.background
  static const Color background = Color(0xFF0F0F23);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF252547);
  static const Color overlay = Color(0xFF2F2F5C);

  // Text colors — DEPRECATED, use AppColors.textPrimary
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textAccent = Color(0xFF7C3AED);

  // Status colors — DEPRECATED, use AppColors.success/error
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border and divider — DEPRECATED, use AppColors.border
  static const Color border = Color(0xFF2E2E52);
  static const Color divider = Color(0xFF1F1F3D);

  // Special effects — DEPRECATED
  static const Color glow = Color(0xFF7C3AED);
  static const Color shadow = Color(0x80000000);
}

// DEPRECATED — use AppTypography instead
class AppTextStyles {
  static const String fontFamily = 'Inter';

  static const TextStyle heading = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFFE2E8F0),
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: Color(0xFFE2E8F0),
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: Color(0xFF94A3B8),
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    color: Color(0xFF94A3B8),
  );
}

// DEPRECATED — use AppSpacing instead
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration verySlow = Duration(milliseconds: 800);
}

// DEPRECATED — use AppSpacing instead
class AppDimensions {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 20.0;
}

/// API configuration constants — KEEP, do not modify
class ApiConstants {
  ApiConstants._();

  static const String pddiktiBaseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';
  static const String kemdikbudBaseUrl = 'https://api-frontend.kemdikbud.go.id';
  static const Duration defaultTimeout = Duration(seconds: 20);
  static const Duration searchTimeout = Duration(seconds: 30);
}
