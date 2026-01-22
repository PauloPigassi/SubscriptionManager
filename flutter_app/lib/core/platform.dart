import 'platform_io.dart' if (dart.library.html) 'platform_web.dart' as impl;

bool get isIOS => impl.isIOS;
bool get isAndroid => impl.isAndroid;
bool get isMacOS => impl.isMacOS;
