import 'dart:io';
import 'package:flutter/foundation.dart';

bool isPhone() {
  if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return false;
  }
  return true;
}
