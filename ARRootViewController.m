// ARRootViewController.m
#import "ARRootViewController.h"
#import "ARVersionViewController.h"
#import "ARDowngradeManager.h"

// 静态字符串解密宏
static inline NSString * OBF(NSString *base64) {
    return [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:base64 options:0] encoding:NSUTF8StringEncoding];
}

@interface ARRootViewController () <UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *allApps;
@property (nonatomic, strong) NSArray *filteredApps;
@property (nonatomic, strong) UISearchController *searchController;
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
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    // 初始化搜索框
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"搜索应用";
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = YES;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    [self loadInstalledApps];
}

- (void)loadInstalledApps {
    // 解密类与方法: LSApplicationWorkspace / defaultWorkspace / allInstalledApplications
    id workspace = [NSClassFromString(OBF(@"TFNBcHBsaWNhdGlvbldvcmtzcGFjZQ==")) performSelector:NSSelectorFromString(OBF(@"ZGVmYXVsdFdvcmtzcGFjZQ=="))];
    NSArray *apps = [workspace performSelector:NSSelectorFromString(OBF(@"YWxsSW5zdGFsbGVkQXBwbGljYXRpb25z"))];
    NSMutableArray *validApps = [NSMutableArray array];
    
    for (id proxy in apps) {
        NSString *bundleID = [proxy performSelector:@selector(bundleIdentifier)];
        if (!bundleID) continue;
        
        // 过滤 com.apple.* (解密字符串: com.apple.)
        if ([bundleID hasPrefix:OBF(@"Y29tLmFwcGxlLg==")]) {
            continue;
        }
        
        // 过滤巨魔应用 (解密方法: bundleURL, 解密字符: _TrollStore)
        NSURL *bundleURL = [proxy respondsToSelector:NSSelectorFromString(OBF(@"YnVuZGxlVVJM"))] ? [proxy performSelector:NSSelectorFromString(OBF(@"YnVuZGxlVVJM"))] : nil;
        if (bundleURL) {
            NSString *trollStorePath = [bundleURL.path stringByAppendingPathComponent:OBF(@"X1Ryb2xsU3RvcmU=")];
            if ([[NSFileManager defaultManager] fileExistsAtPath:trollStorePath]) {
                continue;
            }
        }
        
        [validApps addObject:proxy];
    }
    
    [validApps sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *nameA = [a respondsToSelector:@selector(localizedName)] ? [a performSelector:@selector(localizedName)] : [a performSelector:@selector(bundleIdentifier)];
        NSString *nameB = [b respondsToSelector:@selector(localizedName)] ? [b performSelector:@selector(localizedName)] : [b performSelector:@selector(bundleIdentifier)];
        return [nameA localizedCaseInsensitiveCompare:nameB];
    }];
    
    self.allApps = validApps;
    self.filteredApps = validApps;
    [self.tableView reloadData];
}

#pragma mark - Search Filtering

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text.lowercaseString;
    if (searchText.length == 0) {
        self.filteredApps = self.allApps;
    } else {
        NSMutableArray *results = [NSMutableArray array];
        for (id proxy in self.allApps) {
            NSString *bundleID = [proxy performSelector:@selector(bundleIdentifier)];
            NSString *name = [proxy respondsToSelector:@selector(localizedName)] ? [proxy performSelector:@selector(localizedName)] : bundleID;
            
            if ([name.lowercaseString containsString:searchText] || [bundleID.lowercaseString containsString:searchText]) {
                [results addObject:proxy];
            }
        }
        self.filteredApps = results;
    }
    [self.tableView reloadData];
}

#pragma mark - TableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filteredApps.count;
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
    
    id proxy = self.filteredApps[indexPath.section];
    NSString *bundleID = [proxy performSelector:@selector(bundleIdentifier)];
    NSString *name = [proxy respondsToSelector:@selector(localizedName)] ? [proxy performSelector:@selector(localizedName)] : bundleID;
    
    // 获取当前应用版本号 (解密方法: shortVersionString)
    NSString *version = @"未知";
    SEL versionSel = NSSelectorFromString(OBF(@"c2hvcnRWZXJzaW9uU3RyaW5n"));
    if ([proxy respondsToSelector:versionSel]) {
        version = [proxy performSelector:versionSel];
    }
    
    cell.textLabel.text = name;
    // 将版本号优雅地显示在 bundleID 旁边
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  ·  v%@", bundleID, version];
    
    if ([UIImage respondsToSelector:@selector(_applicationIconImageForBundleIdentifier:format:scale:)]) {
        cell.imageView.image = [UIImage performSelector:@selector(_applicationIconImageForBundleIdentifier:format:scale:) withObject:bundleID withObject:@(1) withObject:@([UIScreen mainScreen].scale)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    BOOL isFirst = (indexPath.row == 0);
    BOOL isLast = (indexPath.row == numberOfRows - 1);

    CGFloat radius = 25.0;
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
    return 65.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 5.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 5.0; }
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [UIView new]; }
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { return [UIView new]; }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id proxy = self.filteredApps[indexPath.section];
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
