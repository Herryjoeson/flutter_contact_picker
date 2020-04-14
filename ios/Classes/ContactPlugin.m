#import "ContactPlugin.h"
#if __has_include(<contact/contact-Swift.h>)
#import <contact/contact-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "contact-Swift.h"
#endif

@implementation ContactPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftContactPlugin registerWithRegistrar:registrar];
}
@end
