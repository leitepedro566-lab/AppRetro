// ARRootViewController.m
#import "ARRootViewController.h"
#import "ARVersionViewController.h"
#import "ARDowngradeManager.h"

@interface LSApplicationWorkspace : NSObject
+ (id)defaultWorkspace;
- (NSArray *)allInstalledApplications;
@end

@interface LSApplicationProxy : NSObject
@property (nonatomic, readonly) NSString *bundleIdentifier;
@property (nonatomic, readonly) NSString *localizedName;
@end

@interface UIImage (Private)
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@interface ARRootViewController ()
@property (nonatomic, strong) NSArray *installedApps;
@end

@implementation ARRootViewController

- (instancetype)init {
    UITableViewStyle style = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) style = UITableViewStyleInsetGrouped;
    return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"AppRetro";
    self.tableView.separatorColor = [UIColor clearColor]; // 药丸 UI 通常去掉分割线更显高级
    self.tableView.showsVerticalScrollIndicator = NO;
    [self loadInstalledApps];
}

- (void)loadInstalledApps {
    id workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    NSArray *allApps = [workspace performSelector:@selector(allInstalledApplications)];
    NSMutableArray *validApps = [NSMutableArray array];
    
    for (id proxy in allApps) {
        NSString *bundleID = [proxy performSelector:@selector(bundleIdentifier)];
        if (bundleID && ![bundleID hasPrefix:@"com.apple."]) {
            [validApps addObject:proxy];
        }
    }
    
    [validApps sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *nameA = [a respondsToSelector:@selector(localizedName)] ? [a performSelector:@selector(localizedName)] : [a performSelector:@selector(bundleIdentifier)];
        NSString *nameB = [b respondsToSelector:@selector(localizedName)] ? [b performSelector:@selector(localizedName)] : [b performSelector:@selector(bundleIdentifier)];
        return [nameA localizedCaseInsensitiveCompare:nameB];
    }];
    
    self.installedApps = validApps;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.installedApps.count; // 每个 App 一个 Section，以形成独立的药丸
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AppCell"];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 8.0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    id proxy = self.installedApps[indexPath.section];
    NSString *bundleID = [proxy performSelector:@selector(bundleIdentifier)];
    NSString *name = [proxy respondsToSelector:@selector(localizedName)] ? [proxy performSelector:@selector(localizedName)] : bundleID;
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = bundleID;
    
    if ([UIImage respondsToSelector:@selector(_applicationIconImageForBundleIdentifier:format:scale:)]) {
        cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:bundleID format:1 scale:[UIScreen mainScreen].scale];
    }
    return cell;
}

// 🎯 核心注入：完美的药丸 (Pill) UI 边角处理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    BOOL isFirst = (indexPath.row == 0);
    BOOL isLast = (indexPath.row == numberOfRows - 1);

    CGFloat radius = 25.0; // 药丸级圆角
    CACornerMask mask = 0;

    if (isFirst && isLast) {
        mask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    } else if (isFirst) {
        mask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    } else if (isLast) {
        mask = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    } else {
        radius = 0;
        mask = 0;
    }

    cell.layer.borderWidth = 0.0;
    cell.layer.borderColor = [UIColor clearColor].CGColor;
    cell.layer.cornerRadius = radius;
    cell.layer.maskedCorners = mask;
    cell.layer.masksToBounds = YES;
    
    if (@available(iOS 14.0, *)) {
        UIBackgroundConfiguration *bg = cell.backgroundConfiguration;
        if (bg) {
            bg.cornerRadius = radius; 
            bg.strokeColor = [UIColor clearColor]; 
            bg.strokeWidth = 0.0;
            cell.backgroundConfiguration = bg;
        }
    } else {
        if (cell.backgroundView) {
            cell.backgroundView.layer.cornerRadius = radius;
            cell.backgroundView.layer.maskedCorners = mask;
            cell.backgroundView.layer.masksToBounds = YES;
            cell.backgroundView.layer.borderWidth = 0.0;
        }
    }
    
    if (@available(iOS 13.0, *)) cell.layer.cornerCurve = kCACornerCurveContinuous;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0; // 稍微增加高度让药丸显得更饱满
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5.0; // 缩小药丸之间的间距
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [UIView new]; }
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { return [UIView new]; }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id proxy = self.installedApps[indexPath.section];
    NSString *bundleID = [proxy performSelector:@selector(bundleIdentifier)];
    NSString *name = [proxy respondsToSelector:@selector(localizedName)] ? [proxy performSelector:@selector(localizedName)] : bundleID;
    
    UIAlertController *loading = [UIAlertController alertControllerWithTitle:@"请稍候" message:@"正在请求服务器获取版本列表..." preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:loading animated:YES completion:nil];
    
    [[ARDowngradeManager sharedManager] fetchTrackIDForBundleID:bundleID completion:^(long long trackId, NSError *error) {
        if (error || trackId == 0) {
            [loading dismissViewControllerAnimated:YES completion:^{
                UIAlertController *errAlert = [UIAlertController alertControllerWithTitle:@"失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                [errAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:errAlert animated:YES completion:nil];
            }];
            return;
        }
        
        [[ARDowngradeManager sharedManager] fetchVersionsForTrackID:trackId completion:^(NSArray *versions, NSError *error) {
            [loading dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    UIAlertController *errAlert = [UIAlertController alertControllerWithTitle:@"失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                    [errAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:errAlert animated:YES completion:nil];
                    return;
                }
                
                ARVersionViewController *versionVC = [[ARVersionViewController alloc] init];
                versionVC.bundleID = bundleID;
                versionVC.appName = name;
                versionVC.trackID = trackId;
                versionVC.versions = [versions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"release_date" ascending:NO]]];
                [self.navigationController pushViewController:versionVC animated:YES];
            }];
        }];
    }];
}
@end
