// Conditional export: use IO implementation when available, otherwise stub.
export 'platform_image_stub.dart' if (dart.library.io) 'platform_image_io.dart';
