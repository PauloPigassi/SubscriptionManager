import 'package:http/http.dart' as http;

http.Client createHttpClient() =>
    throw UnsupportedError('createHttpClient should not be called on web');

bool get isIOS => false;
bool get isAndroid => false;
