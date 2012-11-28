#import "AppDelegate.h"
#import "MainViewController.h"
#import "XtifyCordovaPlugin.h"
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVURLProtocol.h>
#import "XLappMgr.h"
 
@implementation AppDelegate
@synthesize invokeString, launchNotification, snid, appState;
@synthesize window, viewController;
 
- (id) init
{
    if (self = [super init]) {
        XLXtifyOptions *anXtifyOptions=[XLXtifyOptions getXtifyOptions];
        [[XLappMgr get ]initilizeXoptions:anXtifyOptions];
        alreadyHandlingNotification = false;
    }
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [CDVURLProtocol registerURLProtocol];
    return [super init];
}
 
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    NSLog(@"Succeeded registering for push notifications. Device token: %@", devToken);
    [[XLappMgr get] registerWithXtify:devToken ];
}
 
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)pushMessage
{
    NSLog(@"Receiving notification, %@", pushMessage);
    self.launchNotification = pushMessage;
    self.snid = [launchNotification objectForKey:@"SN"];
    [[XLappMgr get] insertSimpleAck:self.snid];
    BOOL ignoreNotificationAlert=NO;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    // get state -applicationState is only supported on 4.0 and above
    if (![[UIApplication sharedApplication] respondsToSelector:@selector(applicationState)])
    {
        ignoreNotificationAlert = NO;
            self.appState = @"Active";
    }
    else
    {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateActive) {
            NSLog(@"Got notification and app is running. Need to display an alert (state is UIApplicationStateActive)");
            ignoreNotificationAlert=NO; // display an alert
                self.appState = @"Active";
        }
           else {
           NSLog(@"Got notification while app was in the background; (user selected the Open button");
           ignoreNotificationAlert =TRUE; // don't display another alert
               self.appState = @"Passive";
       }
        }
    #endif
    if(!ignoreNotificationAlert)
    {
        if(!alreadyHandlingNotification)
            [self showAlert:pushMessage];
        else    {
            NSLog(@"already handling a notification");
        }
    }
    else {
        [[XLappMgr get] insertSimpleAck:[self.launchNotification objectForKey:@"SN"]];
        [self sendPayloadToWebView];
    }
}
  
#pragma UIApplicationDelegate implementation
 
/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url && [url isKindOfClass:[NSURL class]]) {
    NSLog(@"Cordova2.1Sample launchOptions = %@", url);
    }
    self.launchNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"app starting with notif? %@", self.launchNotification);
    if(self.launchNotification != nil)
    {
        self.snid = [launchNotification objectForKey:@"SN"];
        [[XLappMgr get] insertSimpleAck:snid];
        self.appState = @"Passive-off";
        [self storeNotificationForLaunch];
    }
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    self.window.autoresizesSubviews = YES;
    self.viewController = [[MainViewController alloc] init];
    self.viewController.useSplashScreen = YES;
    self.viewController.wwwFolderName = @"www";
    self.viewController.startPage = @"index.html";
    // NOTE: To control the view's frame size, override [self.viewController viewWillAppear:] in your view controller.
    // check whether the current orientation is supported: if it is, keep it, rather than forcing a rotation
    BOOL forceStartupRotation = YES;
    UIDeviceOrientation curDevOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationUnknown == curDevOrientation) {
        // UIDevice isn't firing orientation notifications yet… go look at the status bar
        curDevOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    if (UIDeviceOrientationIsValidInterfaceOrientation(curDevOrientation)) {
        if ([self.viewController supportsOrientation:curDevOrientation]) {
            forceStartupRotation = NO;
        }
    }
    if (forceStartupRotation) {
        UIInterfaceOrientation newOrient;
        if ([self.viewController supportsOrientation:UIInterfaceOrientationPortrait])
            newOrient = UIInterfaceOrientationPortrait;
        else if ([self.viewController supportsOrientation:UIInterfaceOrientationLandscapeLeft])
            newOrient = UIInterfaceOrientationLandscapeLeft;
        else if ([self.viewController supportsOrientation:UIInterfaceOrientationLandscapeRight])
            newOrient = UIInterfaceOrientationLandscapeRight;
        else
            newOrient = UIInterfaceOrientationPortraitUpsideDown;
        NSLog(@"AppDelegate forcing status bar to: %d from: %d", newOrient, curDevOrientation);
        [[UIApplication sharedApplication] setStatusBarOrientation:newOrient];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}
 
- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    // IPhone doesn't support upside down by default, while the IPad does.  Override to allow all orientations always, and let the root view controller decide whats allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);
    return supportedInterfaceOrientations;
}
  
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Application is about to Enter Background");
    [[XLappMgr get] appEnterBackground];
}
 
 //Add or incorporate function into your Application Delegate file
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Application moved from inactive to Active state");
    [[XLappMgr get] appEnterActive];
}
 
//Add or incorporate function into your Application Delegate file
- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Application moved to Foreground");
    [[XLappMgr get] appEnterForeground];    
}
  
-(void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    [[XLappMgr get] applicationWillTerminate];
}
 
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
    NSLog(@"Failed to register with error: %@", error);
    // for simulator, fake a token for debugging
    #if TARGET_IPHONE_SIMULATOR == 1
    // register with xtify
        [[XLappMgr get] registerWithXtify:nil ];
 
#pragma mark -
#pragma mark Using simulator
    NSLog(@"Notification is disabled in simulator, but inbox messages should be working");
#endif
}
  
// for debugging in the background. write to log file
- (void) redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}
  
// this happens while we are running ( in the background, or from within our own app )
// only valid if testxtifycordova-Info.plist specifies a protocol to handle
- (BOOL) application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url) {
        return NO;
    }
    // calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    return YES;
}
 
-(void) showAlert:(NSDictionary *) push{
    self.launchNotification = push;
    NSInteger curBadge = [[XLappMgr get] getSpringBoardBadgeCount];
    [[XLappMgr get] setSpringBoardBadgeCount:curBadge + 1];
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSDictionary *pusdic = [push objectForKey:@"aps"];
    NSDictionary *alrt = [pusdic objectForKey:@"alert"];
    NSString *prodName = [[NSString alloc]initWithString:[info objectForKey:@"CFBundleDisplayName"]];
    NSString *action=[alrt objectForKey:@"action-loc-key"] ==[NSNull null]  ?@"Open" : [alrt objectForKey:@"action-loc-key"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prodName message:[alrt objectForKey:@"body"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:action, nil];
    [alert show];
    [[XLappMgr get] insertSimpleDisp:self.snid];
    alreadyHandlingNotification = true;
}
 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        alreadyHandlingNotification = false;
        [[XLappMgr get] insertSimpleClear:self.snid];
        //cancel clicked ...do your action
    }
    else if (buttonIndex == 1)
    {
        [[XLappMgr get] insertSimpleClick:self.snid];
        [self sendPayloadToWebView];
        alreadyHandlingNotification = false;
    }
}
  
- (void) sendPayloadToWebView
{
    if (launchNotification) {
        XtifyCordovaPlugin *pushHandler = [self getCommandInstance:@"XtifyCordovaPlugin"];
        pushHandler.notificationMessage = self.launchNotification;
        [pushHandler notificationReceived:appState];
        self.launchNotification = nil;
    }
}
 
- (void) storeNotificationForLaunch{
    if (launchNotification) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:launchNotification forKey:@"notif"];
    }
}
 
- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}
 
- (NSString*) pathForResource:(NSString*)resourcepath;
{
    return [self.viewController pathForResource:resourcepath];
}
 
- (void) registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
{
    return;
}
  
- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
    return [ self.viewController webViewDidStartLoad:theWebView ];
}
 
/**
 * Fail Loading With Error
 * Error - If the webpage failed to load display an error with the reason.
 */
- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error
{
    return [ self.viewController webView:theWebView didFailLoadWithError:error ];
}
  
/**
 * Start Loading Request
 * This is where most of the magic happens... We take the request(s) and process the response.
 * From here we can redirect links and other protocols to different internal methods.
 */
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return [ self.viewController webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType ];
}
 
- (BOOL) execute:(CDVInvokedUrlCommand*)command
{
    return [self.viewController execute:command];
}
@end