import 'api_service.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'city': city,
      'street': street,
      'zipCode': zipCode,
      'governorate': governorate,
    };
  }
}

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

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      id: _toInt(json['id']),
      country: _toString(json['country']),
      city: _toString(json['city']),
      street: _toString(json['street']),
      zipCode: _toString(json['zipCode']),
      governorate: _toString(json['governorate']),
    );
  }

  Map<String, dynamic> toMapForUi() {
    return {
      'id': id,
      'title': governorate.isNotEmpty ? governorate : city,
      'details': [
        country,
        governorate,
        city,
        street,
        zipCode,
      ].where((e) => e.isNotEmpty).join(' - '),
      'country': country,
      'city': city,
      'street': street,
      'zipCode': zipCode,
      'governorate': governorate,
      'isDefault': false,
    };
  }
}

class ShippingService {
  static Future<List<dynamic>> getAddresses() async {
    final data = await ApiService.get(
      '/addresses',
      withAuth: true,
    );

    if (data is List) {
      return data.map((e) {
        if (e is Map<String, dynamic>) {
          return AddressResponse.fromJson(e).toMapForUi();
        }

        if (e is Map) {
          return AddressResponse.fromJson(
            Map<String, dynamic>.from(e),
          ).toMapForUi();
        }

        return e;
      }).toList();
    }

    if (data is Map && data['content'] is List) {
      return (data['content'] as List).map((e) {
        if (e is Map) {
          return AddressResponse.fromJson(
            Map<String, dynamic>.from(e),
          ).toMapForUi();
        }
        return e;
      }).toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) {
        if (e is Map) {
          return AddressResponse.fromJson(
            Map<String, dynamic>.from(e),
          ).toMapForUi();
        }
        return e;
      }).toList();
    }

    return [];
  }

  static Future<AddressResponse> getById(int addressId) async {
    final data = await ApiService.get(
      '/addresses/$addressId',
      withAuth: true,
    );

    if (data is Map<String, dynamic>) {
      return AddressResponse.fromJson(data);
    }

    if (data is Map) {
      return AddressResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Invalid address response');
  }

  static Future<AddressResponse> create(AddressRequest request) async {
    final data = await ApiService.post(
      '/addresses',
      request.toJson(),
      withAuth: true,
    );

    if (data is Map<String, dynamic>) {
      return AddressResponse.fromJson(data);
    }

    if (data is Map) {
      return AddressResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Invalid create address response');
  }

  static Future<AddressResponse> update(
    int addressId,
    AddressRequest request,
  ) async {
    final data = await ApiService.put(
      '/addresses/$addressId',
      request.toJson(),
      withAuth: true,
    );

    if (data is Map<String, dynamic>) {
      return AddressResponse.fromJson(data);
    }

    if (data is Map) {
      return AddressResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Invalid update address response');
  }

  static Future<void> delete(int addressId) async {
    await ApiService.delete(
      '/addresses/$addressId',
      withAuth: true,
    );
  }
}

String _toString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}