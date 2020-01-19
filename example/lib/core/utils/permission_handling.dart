import 'package:permission_handler/permission_handler.dart';

class HandlerOfPermissions {
  Future<bool> requestPerm() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
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
