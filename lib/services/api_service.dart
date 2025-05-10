import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API Service class that handles different HTTP implementations for web and mobile
class ApiService {
  /// Make a GET request with appropriate handling for web and mobile platforms
  static Future<http.Response> get(Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    if (kIsWeb) {
      // Web implementation with CORS handling
      return _webGet(url, headers: headers, timeout: timeout);
    } else {
      // Mobile implementation
      return _mobileGet(url, headers: headers, timeout: timeout);
    }
  }

  /// Web-specific GET implementation with CORS handling
  static Future<http.Response> _webGet(Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      // Option 1: Use cors-anywhere proxy (for development only)
      // final String corsProxyUrl = 'https://cors-anywhere.herokuapp.com/';
      // final Uri requestUrl = Uri.parse('$corsProxyUrl${url.toString()}');
      
      // Option 2: Use your own backend proxy (recommended for production)
      // For this to work, you need to set up a backend proxy service
      // final Uri requestUrl = Uri.parse('https://your-backend-proxy.com/proxy?url=${url.toString()}');
      
      // Option 3: Direct request (will work if the API enables CORS)
      final Uri requestUrl = url;
      
      Map<String, String> webHeaders = headers ?? {};
      // Add specific headers that might help with CORS
      webHeaders['Access-Control-Allow-Origin'] = '*';
      
      final request = http.Request('GET', requestUrl);
      request.headers.addAll(webHeaders);
      
      final streamedResponse = await request.send().timeout(
        timeout ?? const Duration(seconds: 15),
      );
      
      return http.Response.fromStream(streamedResponse);
    } catch (e) {
      print('Web API request error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('CORS error detected: Unable to connect to the server from web. Try using a backend proxy.');
      }
      rethrow;
    }
  }

  /// Mobile-specific GET implementation
  static Future<http.Response> _mobileGet(Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      return await http.get(
        url,
        headers: headers,
      ).timeout(
        timeout ?? const Duration(seconds: 15),
      );
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke internet. Periksa koneksi anda.');
    } on http.ClientException {
      throw Exception('Gagal terhubung ke server. Silakan coba lagi nanti.');
    } on TimeoutException {
      throw Exception('Koneksi timeout. Server mungkin sibuk, silakan coba lagi.');
    } catch (e) {
      print('Mobile API request error: $e');
      rethrow;
    }
  }
}