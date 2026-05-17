// Local CORS proxy for Flutter Web development.
// Forwards requests to the real API and adds CORS headers.
// Also accepts self-signed certificates from the target server.
//
// Usage (in a separate terminal):
//   dart run tool/proxy_server.dart
//
// Then run Flutter on web normally — no --disable-web-security needed:
//   flutter run -d chrome
//
// Stop with Ctrl+C.

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';

const _target = 'https://natureccmpany.homeip.net:57571';
const _proxyPort = 8080;

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers':
      'ServiceKey, Authorization, Content-Type, Accept',
};

void main() async {
  // Accept self-signed / untrusted certificates from the target server.
  final ioClient = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  final httpClient = IOClient(ioClient);

  final handler = const Pipeline()
      .addMiddleware(_corsMiddleware)
      .addMiddleware(logRequests())
      .addHandler(proxyHandler(_target, client: httpClient));

  final server = await shelf_io.serve(handler, 'localhost', _proxyPort);

  print('');
  print('  CORS Proxy running');
  print('  Local  : http://localhost:${server.port}');
  print('  Target : $_target');
  print('');
  print('  Run Flutter: flutter run -d chrome');
  print('  Stop proxy : Ctrl+C');
  print('');
}

Handler _corsMiddleware(Handler inner) {
  return (Request request) async {
    // Answer preflight immediately.
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: _corsHeaders);
    }
    final response = await inner(request);
    return response.change(headers: {
      ...response.headers,
      ..._corsHeaders,
    });
  };
}
