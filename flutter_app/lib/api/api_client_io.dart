import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createHttpClient() {
  final c = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15)
    ..idleTimeout = const Duration(seconds: 10);
  return IOClient(c);
}

bool get isIOS => Platform.isIOS;
bool get isAndroid => Platform.isAndroid;
