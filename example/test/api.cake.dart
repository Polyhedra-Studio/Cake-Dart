import 'dart:convert';

import 'package:cake/cake.dart';
import 'package:cake_example/api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() async {
  TestRunner<APIContext>(
    'API Service Test',
    [
      Group('Get Hello World', [
        Test(
          'Response payload should return if successful',
          action: (test) async {
            test.helloResult = await APIService.getHelloWorld();
          },
          assertions: (test) => [
            Expect.equals(actual: test.helloResult, expected: 'Hello world'),
          ],
        ),
        Test(
          'Response payload should return if unsuccessful',
          action: (test) async {
            test.helloResult = await APIService.getHelloWorld();
          },
          assertions: (test) => [
            Expect.equals(actual: test.helloResult, expected: 'Error'),
          ],
          setup: (test) {
            // Fake a failure
            APIService.client = MockClient((request) async {
              return http.Response('', 404);
            });
          },
          teardown: (test) {
            // Reset this to the generic test client for the rest of the calls
            APIService.client = test.client;
          },
        ),
      ]),
      Group('Get User Info', [
        Test(
          'Response payload should return user info if found',
          action: (test) async {
            test.userResult = await APIService.getUserInfo('123');
          },
          assertions: (test) => [
            Expect.equals(
              actual: test.userResult?.id,
              expected: test.userInfo.id,
            ),
            Expect.equals(
              actual: test.userResult?.name,
              expected: test.userInfo.name,
            ),
          ],
        ),
        Test(
          'Response payload should return null if user info is not found',
          action: (test) async => APIService.getUserInfo('garbage data'),
          assertions: (test) => [
            Expect.isNull(test.actual),
          ],
        ),
        Test(
          'Response payload should return null if unsuccessful',
          action: (test) async => APIService.getUserInfo('123'),
          assertions: (test) => [
            Expect.isNull(test.actual),
          ],
          setup: (test) {
            // Fake a failure
            APIService.client = MockClient((request) async {
              return http.Response('', 404);
            });
          },
          teardown: (test) {
            // Reset this to the generic test client for the rest of the calls
            APIService.client = test.client;
          },
        ),
      ]),
    ],
    contextBuilder: APIContext.new,
    setup: (test) async {
      APIService.client = test.client;
    },
  );
}

class APIContext extends Context {
  UserInfo userInfo = UserInfo('123', 'Cake Test');
  late http.Client client;

  String? helloResult;
  UserInfo? userResult;

  APIContext() {
    client = MockClient((request) async {
      // Mock Get Hello World
      if (request.url.path == '/hello-world') {
        return http.Response('Hello world', 200);
      }

      // Mock Get User Info
      if (request.url.path.startsWith('/user/')) {
        if (request.url.path.endsWith('123')) {
          return http.Response(jsonEncode(userInfo.toJson()), 200);
        } else {
          return http.Response('No user found.', 200);
        }
      }
      return http.Response('', 404);
    });
  }
}
