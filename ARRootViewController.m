// ARRootViewController.m
#import "ARRootViewController.h"
#import "ARVersionViewController.h"
#import "ARDowngradeManager.h"

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
    
    // 初始化顶部搜索框
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"搜索应用 (Search Apps)";
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = YES;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    [self loadInstalledApps];
}

- (void)loadInstalledApps {
    // 解密: LSApplicationWorkspace / defaultWorkspace / allInstalledApplications
    id workspace = [NSClassFromString(HEX_DEC("4C534170706C69636174696F6E576F726B7370616365")) performSelector:NSSelectorFromString(HEX_DEC("64656661756C74576F726B7370616365"))];
    NSArray *apps = [workspace performSelector:NSSelectorFromString(HEX_DEC("616C6C496E7374616C6C65644170706C69636174696F6E73"))];
    NSMutableArray *validApps = [NSMutableArray array];
    
    for (id proxy in apps) {
        NSString *bundleID = [proxy performSelector:@selector(bundleIdentifier)];
        if (!bundleID) continue;
        
        // 过滤 com.apple. (系统应用)
        if ([bundleID hasPrefix:HEX_DEC("636F6D2E6170706C652E")]) {
            continue;
        }
        
        // 获取 URL 判断是否包含巨魔 _TrollStore 标识文件
        NSURL *bundleURL = [proxy respondsToSelector:NSSelectorFromString(HEX_DEC("62756E646C6555524C"))] ? [proxy performSelector:NSSelectorFromString(HEX_DEC("62756E646C6555524C"))] : nil;
        if (bundleURL) {
            NSString *trollStorePath = [bundleURL.path stringByAppendingPathComponent:HEX_DEC("5F54726F6C6C53746F7265")]; // "_TrollStore"
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
        // 使用 Value1 样式让副标题显示在右侧
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AppCell"];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 8.0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    id proxy = self.filteredApps[indexPath.section];
    NSString *bundleID = [proxy performSelector:@selector(bundleIdentifier)];
    NSString *name = [proxy respondsToSelector:@selector(localizedName)] ? [proxy performSelector:@selector(localizedName)] : bundleID;
    
    // 获取当前版本号
    NSString *version = @"未知";
    SEL versionSel = NSSelectorFromString(HEX_DEC("73686F727456657273696F6E537472696E67")); // "shortVersionString"
    if ([proxy respondsToSelector:versionSel]) {
        version = [proxy performSelector:versionSel];
    }
    
    cell.textLabel.text = name;
    // 将应用 bundleID 拼接版本号展示在右侧页面边缘
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · v%@", bundleID, version];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    
    if ([UIImage respondsToSelector:@selector(_applicationIconImageForBundleIdentifier:format:scale:)]) {
        cell.imageView.image = [UIImage performSelector:@selector(_applicationIconImageForBundleIdentifier:format:scale:) withObject:bundleID withObject:@(1) withObject:@([UIScreen mainScreen].scale)];
    }
    return cell;
}

// 圆润的药丸边角 UI 处理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat radius = 25.0;
    CACornerMask mask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 65.0; }
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
                // 注意这里用的是 HEX 解密，即使在 Version 页面引用也没问题
                versionVC.versions = [versions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:HEX_DEC("72656C656173655F64617465") ascending:NO]]]; // "release_date"
                [self.navigationController pushViewController:versionVC animated:YES];
            }];
        }];
    }];
}
@end
