import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wanderfund_app/core/services/api_service.dart';
import 'package:wanderfund_app/features/ledger/data/datasources/ledger_remote_data_source.dart';
import 'package:wanderfund_app/features/ledger/data/models/ledger_model.dart';

void main() {
  group('Ledger.fromJson', () {
    test('treats missing transactions as an empty list', () {
      final ledger = Ledger.fromJson({
        'public_id': 'ledger-123',
        'running_balance': 42.5,
      });

      expect(ledger.publicId, 'ledger-123');
      expect(ledger.runningBalance, 42.5);
      expect(ledger.transactions, isEmpty);
    });

    test('treats null transactions as an empty list', () {
      final ledger = Ledger.fromJson({
        'public_id': 'ledger-456',
        'running_balance': 10,
        'transactions': null,
      });

      expect(ledger.publicId, 'ledger-456');
      expect(ledger.runningBalance, 10.0);
      expect(ledger.transactions, isEmpty);
    });
  });

  group('LedgerRemoteDataSourceImpl join request actions', () {
    Future<void> expectActionRequest({
      required String status,
      required String expectedAction,
    }) async {
      http.Request? capturedRequest;

      final source = LedgerRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response(jsonEncode({'ok': true}), 200);
          }),
        ),
      );

      await source.updateJoinRequest(
        publicId: 'fund-123',
        requestId: '01a0ba08-4fe3-7df8-8c47-97f2723d7a71',
        status: status,
        token: 'token',
      );

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'PUT');
      expect(
        capturedRequest!.url.toString(),
        'http://localhost:8080/api/v1/wanderfund/group-join-request/fund-123/$expectedAction',
      );
      expect(jsonDecode(capturedRequest!.body), {
        'user_id': '01a0ba08-4fe3-7df8-8c47-97f2723d7a71',
      });
    }

    test('uses the approve endpoint with a user_id payload', () async {
      await expectActionRequest(status: 'APPROVED', expectedAction: 'approve');
    });

    test('uses the reject endpoint with a user_id payload', () async {
      await expectActionRequest(status: 'REJECTED', expectedAction: 'reject');
    });
  });

  group('LedgerRemoteDataSourceImpl transaction requests', () {
    test('creates a transaction with the supplied API payload', () async {
      http.Request? capturedRequest;
      final source = LedgerRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'body': [
                  {
                    'travel_fund_id': 'fund-123',
                    'amount': 25000.0,
                    'status': 'REQUESTED',
                  },
                ],
                'err': null,
              }),
              201,
            );
          }),
        ),
      );

      final message = await source.createTransaction(
        publicId: 'fund-123',
        action: 'IN',
        amount: 25000,
        currency: 'PHP',
        description: 'Top up',
        referenceId: 'ref-123',
        token: 'token',
      );

      expect(message, 'Transaction request submitted.');
      expect(capturedRequest!.method, 'POST');
      expect(
        capturedRequest!.url.toString(),
        'http://localhost:8080/api/v1/wanderfund/transactions/create',
      );
      expect(jsonDecode(capturedRequest!.body), {
        'travel_fund_id': 'fund-123',
        'action': 'IN',
        'amount': 25000,
        'currency': 'PHP',
        'description': 'Top up',
        'reference_id': 'ref-123',
      });
    });

    test(
      'gets transaction approval requests and parses their transaction IDs',
      () async {
        http.Request? capturedRequest;
        final source = LedgerRemoteDataSourceImpl(
          apiService: ApiService(
            client: MockClient((request) async {
              capturedRequest = request;
              return http.Response(
                jsonEncode({
                  'body': [
                    {
                      'id': 'transaction-123',
                      'travel_fund_id': 'fund-123',
                      'reference_id': 'ref-123',
                      'description': 'Expense',
                      'date_created': '2026-09-27 23:11:02.252688 +0800 +08',
                      'amount': 25000,
                      'initiated_by': 'Jessie James',
                      'status': 'REJECTED',
                      'reject_reason': 'Missing receipt',
                    },
                  ],
                  'err': null,
                }),
                200,
              );
            }),
          ),
        );

        final requests = await source.getTransactionApprovalRequests(
          publicId: 'fund-123',
          status: 'REJECTED',
          token: 'token',
        );

        expect(capturedRequest!.method, 'GET');
        expect(
          capturedRequest!.url.toString(),
          'http://localhost:8080/api/v1/wanderfund/transactions/fund-123/approval-requests?status=REJECTED',
        );
        expect(requests.single.id, 'transaction-123');
        expect(requests.single.travelFundId, 'fund-123');
        expect(requests.single.initiatedBy, 'Jessie James');
        expect(requests.single.status, 'REJECTED');
        expect(requests.single.rejectReason, 'Missing receipt');
        expect(requests.single.createdAt, isNotNull);
      },
    );

    Future<void> expectTransactionAction({
      required String status,
      required String expectedPath,
      required Map<String, dynamic> expectedBody,
      required String expectedMessage,
    }) async {
      http.Request? capturedRequest;
      final source = LedgerRemoteDataSourceImpl(
        apiService: ApiService(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response(jsonEncode({'msg': expectedMessage}), 200);
          }),
        ),
      );

      final message = await source.updateTransactionApproval(
        publicId: 'fund-123',
        transactionId: 'transaction-123',
        status: status,
        reason: status == 'REJECTED' ? 'Missing receipt' : '',
        token: 'token',
      );

      expect(message, expectedMessage);
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, expectedPath);
      expect(jsonDecode(capturedRequest!.body), expectedBody);
    }

    test(
      'approves a transaction and returns the server notification',
      () async {
        await expectTransactionAction(
          status: 'APPROVED',
          expectedPath: '/api/v1/wanderfund/transaction/approve',
          expectedBody: {
            'public_id': 'fund-123',
            'transaction_id': 'transaction-123',
          },
          expectedMessage: 'Approved transaction successfully.',
        );
      },
    );

    test(
      'rejects a transaction with a reason and returns the server notification',
      () async {
        await expectTransactionAction(
          status: 'REJECTED',
          expectedPath: '/api/v1/wanderfund/transaction/reject',
          expectedBody: {
            'public_id': 'fund-123',
            'transaction_id': 'transaction-123',
            'reject_reason': 'Missing receipt',
          },
          expectedMessage: 'Rejected transaction successfully.',
        );
      },
    );
  });
}
