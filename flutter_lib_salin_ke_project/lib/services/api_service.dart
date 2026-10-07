import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  // SEBELUM: 'http://10.0.2.2:8000/api'  (localhost, hanya jalan di emulator)
  // SESUDAH: URL backend hasil deployment
  // Default = URL online. Bisa di-override: flutter run --dart-define=API_BASE_URL=https://...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nama-aplikasi.onrender.com/api',
  );

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Hosting gratis bisa "tidur" -> request pertama bisa lama
  static const Duration _timeout = Duration(seconds: 60);

  Future<List<Product>> getProducts() async {
    final res = await _send(() => http.get(Uri.parse('$baseUrl/products'), headers: _headers));
    final body = jsonDecode(res.body);
    return (body['data'] as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> createProduct(String name, int price, int stock) async {
    final res = await _send(() => http.post(
          Uri.parse('$baseUrl/products'),
          headers: _headers,
          body: jsonEncode({'name': name, 'price': price, 'stock': stock}),
        ));
    return Product.fromJson(jsonDecode(res.body)['data']);
  }

  Future<Product> updateProduct(int id, String name, int price, int stock) async {
    final res = await _send(() => http.put(
          Uri.parse('$baseUrl/products/$id'),
          headers: _headers,
          body: jsonEncode({'name': name, 'price': price, 'stock': stock}),
        ));
    return Product.fromJson(jsonDecode(res.body)['data']);
  }

  Future<void> deleteProduct(int id) async {
    await _send(() => http.delete(Uri.parse('$baseUrl/products/$id'), headers: _headers));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final res = await request().timeout(_timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) return res;

      // 422 = validasi gagal, tampilkan pesan dari Laravel
      String message = 'Terjadi kesalahan (${res.statusCode})';
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['errors'] is Map) {
          message = (body['errors'] as Map).values.expand((v) => v as List).join('\n');
        } else if (body is Map && body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {}
      throw ApiException(message, res.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet.');
    }
  }
}
