import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// اجازه کشیدن با موس، تاچ، ترک‌پد برای اسکرول افقی/عمودی (مخصوصاً وب)
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
