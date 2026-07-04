// ARVersionViewController.h
#import <UIKit/UIKit.h>

__attribute__((visibility("hidden"))) __attribute__((objc_subclassing_restricted))
@interface AR_VersionViewController : UITableViewController
@property (nonatomic, copy) NSString *AR_bundleID;
@property (nonatomic, copy) NSString *AR_appName;
@property (nonatomic, assign) long long AR_trackID;
@property (nonatomic, strong) NSArray *AR_versions;
@property (nonatomic, copy) NSString *AR_appPhysicalPath; 
@end
