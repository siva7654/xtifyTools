
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>
 
@interface AppDelegate : NSObject < UIApplicationDelegate, UIWebViewDelegate, CDVCommandDelegate > {
    NSString* invokeString;
    NSDictionary *launchNotification;
    BOOL alreadyHandlingNotification;
    NSString *snid;
    NSString *appState;
}
  
- (void) redirectConsoleLogToDocumentFolder;
 
// invoke string is passed to your app on launch, this is only valid if you
// edit testxtifycordova-Info.plist to add a protocol
// a simple tutorial can be found here :
// http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html
 
@property (nonatomic,strong ) IBOutlet UIWindow* window;
@property (nonatomic, strong) IBOutlet CDVViewController* viewController;
@property (copy)  NSString* invokeString;
@property (strong, nonatomic) NSDictionary *launchNotification;
@property (strong, nonatomic) NSString *snid;
@property (strong, nonatomic) NSString *appState;
  
@end