import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─── AddressRequest ───────────────────────────────────────────────────────────
// يتطابق مع AddressRequest في الـ backend
class AddressRequest {
  final String country;
  final String city;
  final String street;
  final String zipCode;
  final String governorate;

  AddressRequest({
    required this.country,
    required this.city,
    required this.street,
    required this.zipCode,
    required this.governorate,
  });

  Map<String, dynamic> toJson() => {
        'country': country,
        'city': city,
        'street': street,
        'zipCode': zipCode,
        'governorate': governorate,
      };
}

// ─── AddressResponse ──────────────────────────────────────────────────────────
// يتطابق مع AddressResponse في الـ backend
class AddressResponse {
  final int id;
  final String country;
  final String city;
  final String street;
  final String zipCode;
  final String governorate;

  AddressResponse({
    required this.id,
    required this.country,
    required this.city,
    required this.street,
    required this.zipCode,
    required this.governorate,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) => AddressResponse(
        id: json['id'],
        country: json['country'] ?? '',
        city: json['city'] ?? '',
        street: json['street'] ?? '',
        zipCode: json['zipCode'] ?? '',
        governorate: json['governorate'] ?? '',
      );
}

// ─── ShippingService ──────────────────────────────────────────────────────────
class ShippingService {
  // ✅ غيّر هذا لـ base URL الخاص بالـ backend
  static const String _baseUrl = 'https://your-api-domain.com';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET /addresses ────────────────────────────────────────────────────────
  static Future<List<AddressResponse>> getAddresses() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/addresses'),
      headers: await _headers(),
    );
    _checkStatus(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => AddressResponse.fromJson(e)).toList();
  }

  // ── GET /addresses/{id} ───────────────────────────────────────────────────
  static Future<AddressResponse> getById(int addressId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/addresses/$addressId'),
      headers: await _headers(),
    );
    _checkStatus(response);
    return AddressResponse.fromJson(jsonDecode(response.body));
  }

  // ── POST /addresses → 201 ─────────────────────────────────────────────────
  static Future<AddressResponse> create(AddressRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/addresses'),
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );
    _checkStatus(response, expectedStatus: 201);
    return AddressResponse.fromJson(jsonDecode(response.body));
  }

  // ── PUT /addresses/{id} ───────────────────────────────────────────────────
  static Future<AddressResponse> update(int addressId, AddressRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/addresses/$addressId'),
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );
    _checkStatus(response);
    return AddressResponse.fromJson(jsonDecode(response.body));
  }

  // ── DELETE /addresses/{id} → 204 ─────────────────────────────────────────
  static Future<void> delete(int addressId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/addresses/$addressId'),
      headers: await _headers(),
    );
    _checkStatus(response, expectedStatus: 204);
  }

  static void _checkStatus(http.Response response, {int expectedStatus = 200}) {
    if (response.statusCode != expectedStatus) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }
}