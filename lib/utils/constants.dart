import 'package:flutter/material.dart';

class AppStrings {
  // App
  static const String appName = 'DB Cracker - Tamaengs';
  static const String appAuthor = 'Tamaengs';

  // Screens
  static const String homeTitle = 'DATABASE CRACKER v3.0';
  static const String detailTitle = 'PROFIL SUBJEK';

  // Search
  static const String searchHint = 'masukkan nama target...';
  static const String filterHint = 'filter universitas...';
  static const String emptySearchPrompt =
      'MASUKKAN NAMA TARGET UNTUK MEMULAI SCAN';
  static const String scanningMessage = 'MEMINDAI DATABASE...';
  static const String accessGranted = 'AKSES DIBERIKAN';
  static const String accessDenied = 'AKSES DITOLAK';
  static const String noResultsFound = 'DATA TIDAK DITEMUKAN UNTUK TARGET';
  static const String noFilterResults = 'TIDAK ADA HASIL UNTUK FILTER';
  static const String pleaseEnterSearchTerm = 'ERROR: TARGET BELUM DITENTUKAN';
  static const String errorSearching = 'KONEKSI TERPUTUS:';
  static const String clearFilter = 'BERSIHKAN FILTER';

  // Details
  static const String personalInfoTitle = 'DATA PRIBADI';
  static const String academicInfoTitle = 'DATA INSTITUSI';
  static const String errorLoadingData = 'GAGAL EKSTRAK DATA:';
  static const String noDataAvailable = 'DATA AMAN - AKSES DIBATASI';
  static const String retry = 'COBA LAGI';

  // Student Info Labels
  static const String name = 'Nama Subjek';
  static const String studentId = 'Nomor ID';
  static const String gender = 'Jenis Kelamin';
  static const String entryYear = 'Tahun Masuk';
  static const String registrationType = 'Jenis Pendaftaran';
  static const String currentStatus = 'Status Aktif';
  static const String university = 'Perguruan Tinggi';
  static const String universityCode = 'Kode PT';
  static const String studyProgram = 'Program';
  static const String studyProgramCode = 'Kode Program';
  static const String educationLevel = 'Jenjang';

  // Hacker theme elements
  static const String initiateSearch = 'MULAI SCAN';
  static const String connecting = 'MENGHUBUNGKAN...';
  static const String decrypting = 'DEKRIPSI DATA...';
  static const String securingConnection = 'MENGAMANKAN TUNNEL...';
  static const String bypassingFirewall = 'BYPASS FIREWALL...';
  static const String extractingData = 'EKSTRAK DATA...';
  static const String hackingComplete = 'HACK BERHASIL';

  // Filter
  static const String filterTitle = 'FILTER UNIVERSITAS';
  static const String selectUniversity = 'PILIH UNIVERSITAS';
  static const String filteringInProgress = 'MENERAPKAN FILTER...';
  static const String filterCleared = 'FILTER DIBERSIHKAN';
  static const String filterResults = 'HASIL FILTER';
  static const String reset = 'RESET';
  static const String noFilterResultsFound = 'TIDAK ADA HASIL UNTUK FILTER INI';
}

/// Konstanta warna untuk tema ctOS Watch Dogs
class CtOSColors {
  // Primary ctOS colors
  static const Color primary = Color(0xFF00E5FF); // ctOS cyan blue
  static const Color secondary = Color(0xFF0091EA); // Darker cyan
  static const Color accent = Color(0xFFFFFFFF); // Pure white
  static const Color warning = Color(0xFFFF6D00); // Orange warning

  // Background colors
  static const Color background = Color(0xFF000000); // Pure black
  static const Color surface = Color(0xFF0D1117); // Dark surface
  static const Color surfaceVariant = Color(0xFF161B22); // Lighter surface
  static const Color overlay = Color(0xFF21262D); // Overlay surface

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White text
  static const Color textSecondary = Color(0xFFB3B3B3); // Gray text
  static const Color textTertiary = Color(0xFF7D8590); // Darker gray
  static const Color textAccent = Color(0xFF00E5FF); // Cyan text

  // Status colors
  static const Color success = Color(0xFF00E676); // Green success
  static const Color error = Color(0xFFFF1744); // Red error
  static const Color info = Color(0xFF00B0FF); // Blue info

  // Border and divider colors
  static const Color border = Color(0xFF30363D); // Border gray
  static const Color divider = Color(0xFF21262D); // Divider

  // Special effects
  static const Color glow = Color(0xFF00E5FF); // Glow effect
  static const Color shadow = Color(0x80000000); // Shadow
}

// Backward compatibility
class HackerColors {
  static const Color primary = CtOSColors.primary;
  static const Color accent = CtOSColors.secondary;
  static const Color background = CtOSColors.background;
  static const Color surface = CtOSColors.surface;
  static const Color text = CtOSColors.textPrimary;
  static const Color error = CtOSColors.error;
  static const Color warning = CtOSColors.warning;
  static const Color success = CtOSColors.success;
  static const Color infoBox = CtOSColors.surfaceVariant;
  static const Color highlight = CtOSColors.textAccent;
}

// Durasi animasi
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// Spacing & dimension constants
class AppDimensions {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 20.0;
}

/// Text style constants buat konsistensi typography
class AppTextStyles {
  static const String fontFamily = 'Courier';

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: CtOSColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: CtOSColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: CtOSColors.textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    color: CtOSColors.textSecondary,
  );
}

/// API configuration constants
class ApiConstants {
  static const String pddiktiBaseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';
  static const String kemdikbudBaseUrl = 'https://api-frontend.kemdikbud.go.id';
  static const Duration defaultTimeout = Duration(seconds: 20);
  static const Duration searchTimeout = Duration(seconds: 30);
}
