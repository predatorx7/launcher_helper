import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/widgets.dart';

class HandlerOfPermissions {
  Future<bool> requestPerm() async {
    WidgetsFlutterBinding.ensureInitialized();
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    return this.checkPerm();
  }

  Future<bool> checkPerm() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      print('[HandlerOfPermissions] permission not granted.');
      return false;
    } else {
      return true;
    }
  }
}
