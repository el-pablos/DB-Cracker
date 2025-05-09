import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';

/// Mock service to replace the PDDIKTI API for web development
/// This is useful when developing the web app without a backend proxy
class MockPddiktiService {
  // Random generator for creating sample data
  final Random _random = Random();
  
  // Sample data untuk testing
  final List<Map<String, dynamic>> _sampleMahasiswa = [
    {
      "id": "NDg1MjE1NS0zNWZhLTQ0MzQtYmU3Yi1jNzdiZGZjZjk4YWI=",
      "nama": "Muhammad Akbar",
      "nim": "19102001",
      "nama_pt": "Universitas Indonesia",
      "singkatan_pt": "UI",
      "nama_prodi": "Ilmu Komputer"
    },
    {
      "id": "MmIzODJiNy05MDUxLTRmYjUtYmVlZC02ZDVjYmQ2MjM3Nzc=",
      "nama": "Dewi Sartika",
      "nim": "20102002",
      "nama_pt": "Institut Teknologi Bandung",
      "singkatan_pt": "ITB",
      "nama_prodi": "Teknik Informatika"
    },
    {
      "id": "NjJkMzA3Yi01ZjQ2LTQ4NjYtOWVlZC02NWFjYzk0YWY3M2M=",
      "nama": "Ahmad Rizki",
      "nim": "21102003",
      "nama_pt": "Universitas Gadjah Mada",
      "singkatan_pt": "UGM",
      "nama_prodi": "Sistem Informasi"
    },
    {
      "id": "MGQ2MjdlNS0xYmQ1LTRmZjgtOWUzZC0wZmJlY2EyYTBhMDQ=",
      "nama": "Siti Nurhaliza",
      "nim": "22102004",
      "nama_pt": "Universitas Padjadjaran",
      "singkatan_pt": "UNPAD",
      "nama_prodi": "Manajemen Informatika"
    },
    {
      "id": "YjUyZDA3NS1lNTg4LTRlZDktYWE5Mi1jOWQ2Y2MwZWU2NDc=",
      "nama": "Muhammad Tama",
      "nim": "23102005",
      "nama_pt": "Universitas Diponegoro",
      "singkatan_pt": "UNDIP",
      "nama_prodi": "Teknik Komputer"
    }
  ];

  // Pencarian mahasiswa (mock)
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for web');
    }
    
    // Filter berdasarkan keyword
    final filteredData = _sampleMahasiswa.where((item) {
      final nama = item['nama'].toString().toLowerCase();
      final nim = item['nim'].toString().toLowerCase();
      final pt = item['nama_pt'].toString().toLowerCase();
      final prodi = item['nama_prodi'].toString().toLowerCase();
      
      return nama.contains(keyword.toLowerCase()) || 
             nim.contains(keyword.toLowerCase()) || 
             pt.contains(keyword.toLowerCase()) || 
             prodi.contains(keyword.toLowerCase());
    }).toList();
    
    // Konversi ke model Mahasiswa
    return filteredData.map((item) => Mahasiswa.fromJson(item)).toList();
  }

  // Detail mahasiswa (mock)
// Detail mahasiswa (mock)
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for mahasiswa detail (web)');
    }
    
    // Cari mahasiswa berdasarkan ID di data sample
    final mahasiswaData = _sampleMahasiswa.firstWhere(
      (item) => item['id'] == mahasiswaId,
      orElse: () {
        // If not found by exact ID, create a sample data for any ID
        // This ensures we always return something for any ID
        print('Creating sample data for unknown mahasiswa ID: $mahasiswaId');
        return {
          "id": mahasiswaId,
          "nama": "Mahasiswa ${mahasiswaId.substring(0, min(5, mahasiswaId.length))}",
          "nim": "${10000 + _random.nextInt(90000)}",
          "nama_pt": "Universitas ${_random.nextInt(10)}",
          "singkatan_pt": "UNIV${_random.nextInt(10)}",
          "nama_prodi": "Program Studi ${_random.nextInt(5)}"
        };
      },
    );
    
    // Tambahkan data detail yang tidak ada di data dasar
    final detailData = {
      ...mahasiswaData,
      'id_pt': 'PT${_random.nextInt(10000)}',
      'id_sms': 'SMS${_random.nextInt(10000)}',
      'kode_pt': mahasiswaData['singkatan_pt'] ?? "PT-X",
      'kode_prodi': 'KP${_random.nextInt(100)}',
      'prodi': mahasiswaData['nama_prodi'] ?? "Program Studi X",
      'jenis_daftar': 'Reguler',
      'jenis_kelamin': _random.nextBool() ? 'Laki-laki' : 'Perempuan',
      'jenjang': ['S1', 'D3', 'D4', 'S2', 'S3'][_random.nextInt(5)],
      'status_saat_ini': ['Aktif', 'Lulus', 'Cuti'][_random.nextInt(3)],
      'tahun_masuk': (2015 + _random.nextInt(8)).toString(),
    };
    
    return MahasiswaDetail.fromJson(detailData);
  }

  // Pencarian dosen (mock)
  Future<List<Dosen>> searchDosen(String keyword) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    // Data sample dosen
    final List<Map<String, dynamic>> sampleDosen = [
      {
        "id": "NDg1MjE1NS0zNWZhLTQ0MzQtYmU3Yi1jNzdiZGZjZjk4YWI=",
        "nama": "Dr. Bambang Supriadi",
        "nidn": "0123456789",
        "nama_pt": "Universitas Indonesia",
        "singkatan_pt": "UI",
        "nama_prodi": "Ilmu Komputer"
      },
      {
        "id": "MmIzODJiNy05MDUxLTRmYjUtYmVlZC02ZDVjYmQ2MjM3Nzc=",
        "nama": "Prof. Dr. Siti Rahma",
        "nidn": "9876543210",
        "nama_pt": "Institut Teknologi Bandung",
        "singkatan_pt": "ITB",
        "nama_prodi": "Teknik Informatika"
      }
    ];
    
    // Filter berdasarkan keyword
    final filteredData = sampleDosen.where((item) {
      final nama = item['nama'].toString().toLowerCase();
      final nidn = item['nidn'].toString().toLowerCase();
      final pt = item['nama_pt'].toString().toLowerCase();
      final prodi = item['nama_prodi'].toString().toLowerCase();
      
      return nama.contains(keyword.toLowerCase()) || 
             nidn.contains(keyword.toLowerCase()) || 
             pt.contains(keyword.toLowerCase()) || 
             prodi.contains(keyword.toLowerCase());
    }).toList();
    
    // Konversi ke model Dosen
    return filteredData.map((item) => Dosen.fromJson(item)).toList();
  }

  // Method lainnya bisa ditambahkan sesuai kebutuhan
}