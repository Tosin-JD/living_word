import 'dart:io';
import 'package:android_nav_setting/android_nav_setting.dart';

class NavigationUtils {
  static final AndroidNavSetting _navSetting = AndroidNavSetting();

  /// Checks if the OS uses a navigation bar (3-button or 2-button)
  static Future<bool> hasSystemNavBar() async {
    // iOS - no safe area needed at bottom
    if (Platform.isIOS) {
      return false;
    }

    // Android - check navigation mode
    if (Platform.isAndroid) {
      try {
        int mode = await _navSetting.getNavigationMode();
        // 0 = three-button, 1 = two-button, 2 = gesture
        // Gesture mode means no visible nav bar
        return mode == 0 || mode == 1;
      } catch (e) {
        // Assume nav bar exists if detection fails (safe fallback)
        return true;
      }
    }

    // Other platforms - default to false
    return false;
  }

  /// Gets the bottom padding to use based on system nav bar presence
  static Future<double> getBottomPadding() async {
    final hasNavBar = await hasSystemNavBar();
    return hasNavBar ? 16.0 : 0.0;
  }
}
