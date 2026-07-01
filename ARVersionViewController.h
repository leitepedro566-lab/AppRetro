// ARVersionViewController.h
#import <UIKit/UIKit.h>

@interface ARVersionViewController : UITableViewController
@property (nonatomic, copy) NSString *bundleID;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, assign) long long trackID;
@property (nonatomic, strong) NSArray *versions;
@property (nonatomic, copy) NSString *appPhysicalPath; 
@end
