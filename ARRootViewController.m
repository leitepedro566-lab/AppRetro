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
    self.title = OBF("417070526574726F"); // "AppRetro"
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.arSearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.arSearchController.searchResultsUpdater = self;
    self.arSearchController.obscuresBackgroundDuringPresentation = NO;
    self.arSearchController.searchBar.placeholder = OBF("E6909CE7B4A2"); 
    [self.arSearchController.searchBar setValue:OBF("E58F96E6B688") forKey:OBF("63616E63656C427574746F6E54657874")];
    
    self.navigationItem.searchController = self.arSearchController;
    self.definesPresentationContext = YES;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    UIBarButtonItem *tgItem = [[UIBarButtonItem alloc] initWithTitle:OBF("5447E9A291E98193") style:UIBarButtonItemStylePlain target:self action:@selector(arOpenTGChannel)];
    self.navigationItem.rightBarButtonItem = tgItem;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *barBg = self.navigationController.navigationBar.subviews.firstObject;
        if (barBg) {
            barBg.layer.cornerRadius = 25.0;
            barBg.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
            barBg.layer.masksToBounds = YES;
        }
    });

    [self loadInstalledApps];
}

- (void)arOpenTGChannel {
    NSURL *url = [NSURL URLWithString:OBF("68747470733A2F2F742E6D652F696F7364756D707A7A7A")];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)loadInstalledApps {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id workspace = [NSClassFromString(OBF("4C534170706C69636174696F6E576F726B7370616365")) performSelector:NSSelectorFromString(OBF("64656661756C74576F726B7370616365"))];
    NSArray *apps = [workspace performSelector:NSSelectorFromString(OBF("616C6C496E7374616C6C65644170706C69636174696F6E73"))];
#pragma clang diagnostic pop

    NSMutableArray *validApps = [NSMutableArray array];
    for (id proxy in apps) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString *bundleIdStr = [proxy performSelector:NSSelectorFromString(OBF("62756E646C654964656E746966696572"))]; 
#pragma clang diagnostic pop
        if (!bundleIdStr) continue;
        if ([bundleIdStr hasPrefix:OBF("636F6D2E6170706C652E")]) continue;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSURL *bundleURL = [proxy respondsToSelector:NSSelectorFromString(OBF("62756E646C6555524C"))] ? [proxy performSelector:NSSelectorFromString(OBF("62756E646C6555524C"))] : nil;
#pragma clang diagnostic pop
        if (bundleURL) {
            NSString *appParentDir = [bundleURL.path stringByDeletingLastPathComponent];
            
            NSString *trollStorePath = [appParentDir stringByAppendingPathComponent:OBF("5F54726F6C6C53746F7265")];
            if ([[NSFileManager defaultManager] fileExistsAtPath:trollStorePath]) continue; 
            
            NSString *itunesPath = [appParentDir stringByAppendingPathComponent:OBF("6954756E65734D657461646174612E706C697374")];
            NSString *bundleMetaPath = [appParentDir stringByAppendingPathComponent:OBF("42756E646C654D657461646174612E706C697374")]; 
            if (![[NSFileManager defaultManager] fileExistsAtPath:itunesPath] || ![[NSFileManager defaultManager] fileExistsAtPath:bundleMetaPath]) {
                continue;
            }
            
        } else {
            continue;
        }
        [validApps addObject:proxy];
    }
    
    [validApps sortUsingComparator:^NSComparisonResult(id a, id b) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL nameSel = NSSelectorFromString(OBF("6C6F63616C697A65644E616D65")); 
        SEL shortNameSel = NSSelectorFromString(OBF("6C6F63616C697A656453686F72744E616D65"));
        SEL bundleSel = NSSelectorFromString(OBF("62756E646C654964656E746966696572"));
        
        NSString *nameA = nil;
        if ([a respondsToSelector:nameSel]) nameA = [a performSelector:nameSel];
        if (!nameA && [a respondsToSelector:shortNameSel]) nameA = [a performSelector:shortNameSel];
        if (!nameA) nameA = [a performSelector:bundleSel];
        
        NSString *nameB = nil;
        if ([b respondsToSelector:nameSel]) nameB = [b performSelector:nameSel];
        if (!nameB && [b respondsToSelector:shortNameSel]) nameB = [b performSelector:shortNameSel];
        if (!nameB) nameB = [b performSelector:bundleSel];
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
            SEL nameSel = NSSelectorFromString(OBF("6C6F63616C697A65644E616D65"));
            SEL shortNameSel = NSSelectorFromString(OBF("6C6F63616C697A656453686F72744E616D65"));
            SEL bundleSel = NSSelectorFromString(OBF("62756E646C654964656E746966696572"));
            
            NSString *bundleIdStr = [proxy performSelector:bundleSel];
            NSString *name = nil;
            if ([proxy respondsToSelector:nameSel]) name = [proxy performSelector:nameSel];
            if (!name && [proxy respondsToSelector:shortNameSel]) name = [proxy performSelector:shortNameSel];
            if (!name) name = bundleIdStr;
#pragma clang diagnostic pop
            
            if ([name.lowercaseString containsString:searchText] || [bundleIdStr.lowercaseString containsString:searchText]) {
                [results addObject:proxy];
            }
        }
        self.arFilteredApps = results;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.arFilteredApps.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 1; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = OBF("41707043656C6C"); 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 12.0;
    }
    
    id proxy = self.arFilteredApps[indexPath.section];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL nameSel = NSSelectorFromString(OBF("6C6F63616C697A65644E616D65"));
    SEL shortNameSel = NSSelectorFromString(OBF("6C6F63616C697A656453686F72744E616D65"));
    SEL bundleSel = NSSelectorFromString(OBF("62756E646C654964656E746966696572"));
    
    NSString *bundleIdStr = [proxy performSelector:bundleSel];
    NSString *name = nil;
    if ([proxy respondsToSelector:nameSel]) name = [proxy performSelector:nameSel];
    if (!name && [proxy respondsToSelector:shortNameSel]) name = [proxy performSelector:shortNameSel];
    if (!name) name = bundleIdStr;
    
    NSString *version = OBF("2D"); 
    SEL versionSel = NSSelectorFromString(OBF("73686F727456657273696F6E537472696E67")); 
    if ([proxy respondsToSelector:versionSel]) {
        version = [proxy performSelector:versionSel];
    }
#pragma clang diagnostic pop
    
    cell.textLabel.text = name;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    cell.detailTextLabel.text = bundleIdStr; 
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    
    UILabel *rightVerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 30)];
    rightVerLabel.text = [NSString stringWithFormat:OBF("762540"), version]; 
    rightVerLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    rightVerLabel.textColor = [UIColor secondaryLabelColor];
    rightVerLabel.textAlignment = NSTextAlignmentRight;
    cell.accessoryView = rightVerLabel; 
    
    SEL iconSel = NSSelectorFromString(OBF("5F6170706C69636174696F6E49636F6E496D616765466F7242756E646C654964656E7469666965723A666F726D61743A7363616C653A"));
    if ([UIImage respondsToSelector:iconSel]) {
        NSMethodSignature *sig = [UIImage methodSignatureForSelector:iconSel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:[UIImage class]]; [inv setSelector:iconSel]; [inv setArgument:&bundleIdStr atIndex:2];
        int format = 1; [inv setArgument:&format atIndex:3];
        CGFloat scale = [UIScreen mainScreen].scale; [inv setArgument:&scale atIndex:4]; [inv invoke];
        UIImage *__unsafe_unretained appIcon = nil; [inv getReturnValue:&appIcon];
        cell.imageView.image = appIcon;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat radius = 22.0;
    CACornerMask mask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    cell.layer.borderWidth = 0.0; cell.layer.borderColor = [UIColor clearColor].CGColor;
    cell.layer.cornerRadius = radius; cell.layer.maskedCorners = mask; cell.layer.masksToBounds = YES;
    
    if (@available(iOS 14.0, *)) {
        UIBackgroundConfiguration *bg = cell.backgroundConfiguration;
        if (bg) {
            bg.cornerRadius = radius; bg.strokeColor = [UIColor clearColor]; bg.strokeWidth = 0.0;
            cell.backgroundConfiguration = bg;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 70.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 4.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 4.0; }
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [UIView new]; }
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { return [UIView new]; }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id proxy = self.arFilteredApps[indexPath.section];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL nameSel = NSSelectorFromString(OBF("6C6F63616C697A65644E616D65"));
    SEL shortNameSel = NSSelectorFromString(OBF("6C6F63616C697A656453686F72744E616D65"));
    SEL bundleSel = NSSelectorFromString(OBF("62756E646C654964656E746966696572"));
    
    NSString *bundleIdStr = [proxy performSelector:bundleSel];
    NSString *name = nil;
    if ([proxy respondsToSelector:nameSel]) name = [proxy performSelector:nameSel];
    if (!name && [proxy respondsToSelector:shortNameSel]) name = [proxy performSelector:shortNameSel];
    if (!name) name = bundleIdStr;
    
    NSURL *bundleURL = [proxy respondsToSelector:NSSelectorFromString(OBF("62756E646C6555524C"))] ? [proxy performSelector:NSSelectorFromString(OBF("62756E646C6555524C"))] : nil;
    NSString *fullAppPath = bundleURL.path;
#pragma clang diagnostic pop
    
    // 🎯 核心改动：不再原地加载，而是直接创建 Controller 并推送，把网络请求转移到了版本页
    ARVersionViewController *versionVC = [[ARVersionViewController alloc] init];
    versionVC.bundleID = bundleIdStr; 
    versionVC.appName = name;
    versionVC.appPhysicalPath = fullAppPath; 
    
    [self.navigationController pushViewController:versionVC animated:YES];
}
@end
