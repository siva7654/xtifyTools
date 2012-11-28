#import <Cordova/CDVViewController.h>
#import "XtifyCordovaPlugin.h"
 
@interface MainViewController : CDVViewController{
    XtifyCordovaPlugin *xPlugin;
    CDVCordovaView * wv;
}
 
@property (strong, nonatomic) XtifyCordovaPlugin *xPlugin;
@property (strong, nonatomic) CDVCordovaView *wvm;
@end