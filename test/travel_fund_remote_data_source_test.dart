import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wanderfund_app/core/error/exceptions.dart';
import 'package:wanderfund_app/core/services/api_service.dart';
import 'package:wanderfund_app/features/travel_funds/data/datasources/travel_fund_remote_data_source.dart';

void main() {
  group('TravelFundRemoteDataSourceImpl', () {
    test('gets the invite code for a public ID', () async {
      http.Request? capturedRequest;
      final source = TravelFundRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'body': {
                  'id': 'invite-1',
                  'invite_code': 'b38667da-54b8-49',
                  'status': 'ACTIVE',
                },
                'err': null,
              }),
              200,
            );
          }),
        ),
      );

      final result = await source.getTravelFundInviteCode(
        publicId: 'fund-123',
        token: 'token',
      );

      expect(result, 'b38667da-54b8-49');
      expect(capturedRequest!.method, 'GET');
      expect(
        capturedRequest!.url.toString(),
        'https://wanderfund-backend.onrender.com/api/v1/wanderfund/invite/fund-123',
      );
      expect(capturedRequest!.headers['authorization'], 'Bearer token');
    });

    test('throws when the invite response has no code', () async {
      final source = TravelFundRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            return http.Response(jsonEncode({'body': {'status': 'ACTIVE'}}), 200);
          }),
        ),
      );

      expect(
        () => source.getTravelFundInviteCode(publicId: 'fund-123', token: 'token'),
        throwsA(isA<ServerException>()),
      );
    });

    test('returns the public ID when creating a travel fund', () async {
      final source = TravelFundRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            return http.Response(
              jsonEncode({'body': {'public_id': 'fund-123'}}),
              200,
            );
          }),
        ),
      );

      final result = await source.createTravelFund(
        name: 'Trip',
        description: 'Shared trip',
        baseCurrency: 'PHP',
        token: 'token',
      );

      expect(result, 'fund-123');
    });

    test('returns an empty list when the response body is null', () async {
      final source = TravelFundRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            return http.Response(jsonEncode({'body': null}), 200);
          }),
        ),
      );

      final result = await source.getTravelFunds(userId: 'user-1', token: 'token');

      expect(result, isEmpty);
    });

    test('throws when the response is not a map', () async {
      final source = TravelFundRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            return http.Response(jsonEncode(['not', 'a', 'map']), 200);
          }),
        ),
      );

      expect(
        () => source.getTravelFunds(userId: 'user-1', token: 'token'),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws when the body is not a list', () async {
      final source = TravelFundRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            return http.Response(jsonEncode({'body': {'not': 'a list'}}), 200);
          }),
        ),
      );

      expect(
        () => source.getTravelFunds(userId: 'user-1', token: 'token'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
