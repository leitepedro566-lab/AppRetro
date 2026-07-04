// ARAppDelegate.h
#import <UIKit/UIKit.h>

// 🎯 彻底隐藏类的可见性，并防止子类化泄露结构
__attribute__((visibility("hidden"))) __attribute__((objc_subclassing_restricted))
@interface AR_AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end
