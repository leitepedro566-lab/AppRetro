// ARAppDelegate.m
#import "ARAppDelegate.h"
#import "ARRootViewController.h"

@implementation ARAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    ARRootViewController *rootVC = [[ARRootViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    // 强制大标题配合药丸UI更美观
    nav.navigationBar.prefersLargeTitles = YES;
    
    // 🎯 顶栏（导航栏）底部两侧全局圆角 (上方两个角不变化，只有下方两角圆角)
    nav.navigationBar.layer.cornerRadius = 25.0;
    nav.navigationBar.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    nav.navigationBar.layer.masksToBounds = YES;
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
