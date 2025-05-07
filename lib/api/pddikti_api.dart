import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';

class PddiktiApi {
  // Base URL for the API
  final String baseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';
  
  // Headers to mimic the browser request
  Map<String, String> get _headers => {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br, zstd',
    'Accept-Language': 'en-US,en;q=0.9,mt;q=0.8',
    'Connection': 'keep-alive',
    'DNT': '1',
    'Host': 'api-pddikti.kemdiktisaintek.go.id',
    'Origin': 'https://pddikti.kemdiktisaintek.go.id',
    'Referer': 'https://pddikti.kemdiktisaintek.go.id/',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-site',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0',
    'X-User-IP': '103.47.132.29', // This should be dynamic in a real app
    'sec-ch-ua': '"Microsoft Edge";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"'
  };

  // Helper method to parse strings for URL
  String _parseString(String text) {
    return Uri.encodeComponent(text);
  }

  // Search for all entities (mahasiswa, dosen, pt, prodi)
  Future<Map<String, dynamic>> searchAll(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pencarian/all/${_parseString(keyword)}'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search all data: ${response.statusCode}');
    }
  }

  // Search specifically for students
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pencarian/mhs/${_parseString(keyword)}'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['mahasiswa'] != null) {
        return (data['mahasiswa'] as List)
            .map((item) => Mahasiswa.fromJson(item))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to search students: ${response.statusCode}');
    }
  }

  // Get detailed information about a specific student
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/detail/mhs/${_parseString(mahasiswaId)}'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['mahasiswa'] != null && data['mahasiswa'].isNotEmpty) {
        return MahasiswaDetail.fromJson(data['mahasiswa'][0]);
      }
      throw Exception('No student details found');
    } else {
      throw Exception('Failed to get student details: ${response.statusCode}');
    }
  }
}