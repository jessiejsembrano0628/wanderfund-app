import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wanderfund_app/core/services/api_service.dart';
import 'package:wanderfund_app/features/auth/data/datasources/auth_remote_data_source.dart';

void main() {
  test(
    'gets the current user from the versioned API with the saved token',
    () async {
      http.Request? capturedRequest;
      final source = AuthRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'id': 'user-123',
                  'email': 'user@example.com',
                  'name': 'Wander User',
                  'createdAt': '2025-01-01T00:00:00.000Z',
                },
              }),
              200,
            );
          }),
        ),
      );

      final user = await source.getCurrentUser('saved-token');

      expect(capturedRequest!.method, 'GET');
      expect(
        capturedRequest!.url.toString(),
        'http://localhost:8080/api/v1/user',
      );
      expect(capturedRequest!.headers['authorization'], 'Bearer saved-token');
      expect(user.id, 'user-123');
    },
  );
}
