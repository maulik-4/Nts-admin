import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/network/dio_client.dart';

void main() {
  test(
    'PathNormalizerInterceptor prevents duplicate /api/api/ path resolution',
    () {
      final interceptor = PathNormalizerInterceptor();

      final testCases = [
        ('/api/firms/', '/firms/'),
        ('/api/auth/users/', '/auth/users/'),
        ('/api/admin/create-firm/', '/admin/create-firm/'),
        ('api/cases/', '/cases/'),
        ('/clients/', '/clients/'),
        ('/plans/', '/plans/'),
        ('/subscriptions/create-order/', '/subscriptions/create-order/'),
      ];

      for (final testCase in testCases) {
        final options = RequestOptions(
          path: testCase.$1,
          baseUrl: 'https://api.hphighcourt.site/api',
        );

        interceptor.onRequest(options, RequestInterceptorHandler());
        expect(options.path, testCase.$2);
        expect(options.uri.toString().contains('/api/api/'), isFalse);
        expect(
          options.uri.toString().startsWith(
            'https://api.hphighcourt.site/api/',
          ),
          isTrue,
        );
      }
    },
  );
}
