#import "LauncherAssistPlugin.h"
#import <launcher_assist/launcher_assist-Swift.h>

@implementation LauncherAssistPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLauncherAssistPlugin registerWithRegistrar:registrar];
}
@end
