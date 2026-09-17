import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/clients/data/models/client_model.dart';

void main() {
  group('Client Model Tests', () {
    test('parses full JSON client successfully', () {
      final json = {
        'id': 4,
        'created_at': '2026-09-16T07:29:06.207143Z',
        'updated_at': '2026-09-16T07:29:06.207212Z',
        'is_active': true,
        'is_deleted': false,
        'name': 'Acme Legal Services',
        'phone': '9876543210',
        'email': 'contact@acme.com',
        'address': '123 Commercial Hub',
        'city': 'Shimla',
        'id_proof': 'https://example.com/id.pdf',
        'firm': 15,
      };

      final client = Client.fromJson(json);

      expect(client.id, 4);
      expect(client.name, 'Acme Legal Services');
      expect(client.phone, '9876543210');
      expect(client.email, 'contact@acme.com');
      expect(client.city, 'Shimla');
      expect(client.firm, 15);
      expect(client.isActive, true);
      expect(client.createdAt, isNotNull);
    });

    test('handles missing or nullable fields gracefully', () {
      final json = {
        'id': '10',
        'name': 'Jane Doe',
        'phone': '9123456780',
        'address': 'Court Road',
        'firm': '15',
      };

      final client = Client.fromJson(json);

      expect(client.id, 10);
      expect(client.name, 'Jane Doe');
      expect(client.email, isNull);
      expect(client.city, isNull);
      expect(client.idProof, isNull);
      expect(client.firm, 15);
      expect(client.isActive, true);
    });

    test('CreateClientRequest formats json correctly', () {
      const req = CreateClientRequest(
        name: '  Test Name  ',
        phone: '  9876543210  ',
        email: 'test@example.com',
        address: 'Main St',
        city: 'Shimla',
        firm: 15,
      );

      final json = req.toJson();

      expect(json['name'], 'Test Name');
      expect(json['phone'], '9876543210');
      expect(json['email'], 'test@example.com');
      expect(json['firm'], 15);
    });

    test('UpdateClientRequest only includes provided fields', () {
      const req = UpdateClientRequest(city: 'Kullu', isActive: false);

      final json = req.toJson();

      expect(json['city'], 'Kullu');
      expect(json['is_active'], false);
      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('phone'), isFalse);
    });
  });
}
