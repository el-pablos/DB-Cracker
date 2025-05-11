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
  static const String emptySearchPrompt = 'MASUKKAN NAMA TARGET UNTUK MEMULAI SCAN';
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

class HackerColors {
  static const Color primary = Color(0xFF00FF00); // Hijau terang
  static const Color accent = Color(0xFF00CCFF); // Cyan
  static const Color surface = Color(0xFF101820); // Biru gelap
  static const Color background = Color(0xFF000000); // Hitam
  static const Color text = Color(0xFFCCFFCC); // Hijau muda
  static const Color error = Color(0xFFFF0033); // Merah
  static const Color warning = Color(0xFFFFCC00); // Kuning
  static const Color success = Color(0xFF00FF00); // Hijau
  static const Color infoBox = Color(0xFF001030); // Navy gelap
  static const Color highlight = Color(0xFF00FF33); // Hijau neon
}

// Durasi animasi
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}