// ARRootViewController.m
#import "ARRootViewController.h"
#import "ARVersionViewController.h"
#import "ARDowngradeManager.h"

@interface ARRootViewController () <UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *arAllApps;
@property (nonatomic, strong) NSArray *arFilteredApps;
@property (nonatomic, strong) UISearchController *arSearchController;
@end

@implementation ARRootViewController

- (instancetype)init {
    UITableViewStyle style = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) style = UITableViewStyleInsetGrouped;
    return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = HEX_DEC("417070526574726F"); // "AppRetro"
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    // 初始化顶部搜索框
    self.arSearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.arSearchController.searchResultsUpdater = self;
    self.arSearchController.obscuresBackgroundDuringPresentation = NO;
    self.arSearchController.searchBar.placeholder = HEX_DEC("E6909CE7B4A2E5BA94E794A8"); // "搜索应用"
    self.navigationItem.searchController = self.arSearchController;
    self.definesPresentationContext = YES;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    [self loadInstalledApps];
}

- (void)loadInstalledApps {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // 解密: LSApplicationWorkspace / defaultWorkspace / allInstalledApplications
    id workspace = [NSClassFromString(HEX_DEC("4C534170706C69636174696F6E576F726B7370616365")) performSelector:NSSelectorFromString(HEX_DEC("64656661756C74576F726B7370616365"))];
    NSArray *apps = [workspace performSelector:NSSelectorFromString(HEX_DEC("616C6C496E7374616C6C65644170706C69636174696F6E73"))];
    
#pragma clang diagnostic pop

    NSMutableArray *validApps = [NSMutableArray array];
    
    for (id proxy in apps) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString *bundleID = [proxy performSelector:NSSelectorFromString(HEX_DEC("62756E646C654964656E746966696572"))]; // "bundleIdentifier"
#pragma clang diagnostic pop
        if (!bundleID) continue;
        
        // 过滤 com.apple. (系统应用)
        if ([bundleID hasPrefix:HEX_DEC("636F6D2E6170706C652E")]) continue;
        
        // 检查 _TrollStore 标识文件
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSURL *bundleURL = [proxy respondsToSelector:NSSelectorFromString(HEX_DEC("62756E646C6555524C"))] ? [proxy performSelector:NSSelectorFromString(HEX_DEC("62756E646C6555524C"))] : nil;
#pragma clang diagnostic pop
        if (bundleURL) {
            NSString *trollStorePath = [bundleURL.path stringByAppendingPathComponent:HEX_DEC("5F54726F6C6C53746F7265")]; // "_TrollStore"
            if ([[NSFileManager defaultManager] fileExistsAtPath:trollStorePath]) continue;
        }
        [validApps addObject:proxy];
    }
    
    [validApps sortUsingComparator:^NSComparisonResult(id a, id b) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL nameSel = NSSelectorFromString(HEX_DEC("6C6F63616C697A65644E616D65")); // "localizedName"
        SEL bundleSel = NSSelectorFromString(HEX_DEC("62756E646C654964656E746966696572"));
        NSString *nameA = [a respondsToSelector:nameSel] ? [a performSelector:nameSel] : [a performSelector:bundleSel];
        NSString *nameB = [b respondsToSelector:nameSel] ? [b performSelector:nameSel] : [b performSelector:bundleSel];
#pragma clang diagnostic pop
        return [nameA localizedCaseInsensitiveCompare:nameB];
    }];
    
    self.arAllApps = validApps;
    self.arFilteredApps = validApps;
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text.lowercaseString;
    if (searchText.length == 0) {
        self.arFilteredApps = self.arAllApps;
    } else {
        NSMutableArray *results = [NSMutableArray array];
        for (id proxy in self.arAllApps) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            SEL nameSel = NSSelectorFromString(HEX_DEC("6C6F63616C697A65644E616D65"));
            SEL bundleSel = NSSelectorFromString(HEX_DEC("62756E646C654964656E746966696572"));
            NSString *bundleID = [proxy performSelector:bundleSel];
            NSString *name = [proxy respondsToSelector:nameSel] ? [proxy performSelector:nameSel] : bundleID;
#pragma clang diagnostic pop
            if ([name.lowercaseString containsString:searchText] || [bundleID.lowercaseString containsString:searchText]) {
                [results addObject:proxy];
            }
        }
        self.arFilteredApps = results;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arFilteredApps.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = HEX_DEC("41707043656C6C"); // "AppCell"
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 8.0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    id proxy = self.arFilteredApps[indexPath.section];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL nameSel = NSSelectorFromString(HEX_DEC("6C6F63616C697A65644E616D65"));
    SEL bundleSel = NSSelectorFromString(HEX_DEC("62756E646C654964656E746966696572"));
    NSString *bundleID = [proxy performSelector:bundleSel];
    NSString *name = [proxy respondsToSelector:nameSel] ? [proxy performSelector:nameSel] : bundleID;
    
    // 获取当前版本号 (shortVersionString)
    NSString *version = @"-";
    SEL versionSel = NSSelectorFromString(HEX_DEC("73686F727456657273696F6E537472696E67")); 
    if ([proxy respondsToSelector:versionSel]) {
        version = [proxy performSelector:versionSel];
    }
#pragma clang diagnostic pop
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · v%@", bundleID, version];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    
    // 安全动态调用多参 UIImage 私有方法
    SEL iconSel = NSSelectorFromString(HEX_DEC("5F6170706C69636174696F6E49636F6E496D616765466F7242756E646C654964656E7469666965723A666F726D61743A7363616C653A"));
    if ([UIImage respondsToSelector:iconSel]) {
        NSMethodSignature *sig = [UIImage methodSignatureForSelector:iconSel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:[UIImage class]];
        [inv setSelector:iconSel];
        [inv setArgument:&bundleID atIndex:2];
        int format = 1;
        [inv setArgument:&format atIndex:3];
        CGFloat scale = [UIScreen mainScreen].scale;
        [inv setArgument:&scale atIndex:4];
        [inv invoke];
        
        UIImage *__unsafe_unretained appIcon = nil;
        [inv getReturnValue:&appIcon];
        cell.imageView.image = appIcon;
    }
    
    return cell;
}

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
    id proxy = self.arFilteredApps[indexPath.section];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL nameSel = NSSelectorFromString(HEX_DEC("6C6F63616C697A65644E616D65"));
    SEL bundleSel = NSSelectorFromString(HEX_DEC("62756E646C654964656E746966696572"));
    NSString *bundleID = [proxy performSelector:bundleSel];
    NSString *name = [proxy respondsToSelector:nameSel] ? [proxy performSelector:nameSel] : bundleID;
#pragma clang diagnostic pop
    
    UIAlertController *loading = [UIAlertController alertControllerWithTitle:HEX_DEC("E8AFB7E7A88DE58099") // "请稍候"
                                                                     message:HEX_DEC("E6ADA3E59CA8E8AFB7E6B182E69C8DE58AA1E599A8E88EB7E58F96E78988E69CACE58897E8A1A82E2E2E") // "正在请求..."
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:loading animated:YES completion:nil];
    
    [[ARDowngradeManager sharedManager] fetchTrackIDForBundleID:bundleID completion:^(long long trackId, NSError *error) {
        if (error || trackId == 0) {
            [loading dismissViewControllerAnimated:YES completion:^{
                UIAlertController *errAlert = [UIAlertController alertControllerWithTitle:HEX_DEC("E5A4B1E8B4A5") // "失败"
                                                                                  message:error.localizedDescription 
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                [errAlert addAction:[UIAlertAction actionWithTitle:HEX_DEC("E7A1AEE5AE9A") style:UIAlertActionStyleCancel handler:nil]]; // "确定"
                [self presentViewController:errAlert animated:YES completion:nil];
            }];
            return;
        }
        
        [[ARDowngradeManager sharedManager] fetchVersionsForTrackID:trackId completion:^(NSArray *versions, NSError *error) {
            [loading dismissViewControllerAnimated:YES completion:^{
                if (error) {
                    UIAlertController *errAlert = [UIAlertController alertControllerWithTitle:HEX_DEC("E5A4B1E8B4A5") 
                                                                                      message:error.localizedDescription 
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                    [errAlert addAction:[UIAlertAction actionWithTitle:HEX_DEC("E7A1AEE5AE9A") style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:errAlert animated:YES completion:nil];
                    return;
                }
                
                ARVersionViewController *versionVC = [[ARVersionViewController alloc] init];
                versionVC.bundleID = bundleID;
                versionVC.appName = name;
                versionVC.trackID = trackId;
                versionVC.versions = [versions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:HEX_DEC("72656C656173655F64617465") ascending:NO]]]; // "release_date"
                [self.navigationController pushViewController:versionVC animated:YES];
            }];
        }];
    }];
}
@end
