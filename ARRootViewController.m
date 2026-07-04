// ARRootViewController.m
#import "ARRootViewController.h"
#import "ARVersionViewController.h"
#import "ARDowngradeManager.h"

@interface AR_RootViewController () <UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *AR_arAllApps;
@property (nonatomic, strong) NSArray *AR_arFilteredApps;
@property (nonatomic, strong) UISearchController *AR_arSearchController;
@end

@implementation AR_RootViewController

- (instancetype)init {
    UITableViewStyle style = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) style = UITableViewStyleInsetGrouped;
    return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OBF("417070526574726F");
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.AR_arSearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.AR_arSearchController.searchResultsUpdater = self;
    self.AR_arSearchController.obscuresBackgroundDuringPresentation = NO;
    self.AR_arSearchController.searchBar.placeholder = OBF("E6909CE7B4A2"); 
    [self.AR_arSearchController.searchBar setValue:OBF("E58F96E6B688") forKey:OBF("63616E63656C427574746F6E54657874")];
    
    self.navigationItem.searchController = self.AR_arSearchController;
    self.definesPresentationContext = YES;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    UIBarButtonItem *tgItem = [[UIBarButtonItem alloc] initWithTitle:OBF("5447E9A291E98193") style:UIBarButtonItemStylePlain target:self action:@selector(AR_arOpenTGChannel)];
    self.navigationItem.leftBarButtonItem = tgItem;

    [self AR_setupRightMenuButton];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *barBg = self.navigationController.navigationBar.subviews.firstObject;
        if (barBg) {
            barBg.layer.cornerRadius = 25.0;
            barBg.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
            barBg.layer.masksToBounds = YES;
        }
    });

    [self AR_loadInstalledApps];
}

- (void)AR_setupRightMenuButton {
    BOOL useLocalBackup = [[NSUserDefaults standardUserDefaults] boolForKey:@"ARUseLocalBackup"];
    
    UIAction *serverAction = [UIAction actionWithTitle:@"从服务器获取版本" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ARUseLocalBackup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self AR_setupRightMenuButton]; 
    }];
    serverAction.state = useLocalBackup ? UIMenuElementStateOff : UIMenuElementStateOn;
    
    UIAction *localAction = [UIAction actionWithTitle:@"使用本地备份版本" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ARUseLocalBackup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self AR_setupRightMenuButton];
    }];
    localAction.state = useLocalBackup ? UIMenuElementStateOn : UIMenuElementStateOff;
    
    NSDate *lastBackup = [[NSUserDefaults standardUserDefaults] objectForKey:@"ARLocalDowngradeBackupTime"];
    NSString *backupTitle = @"备份版本";
    if (lastBackup) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM-dd HH:mm"];
        backupTitle = [NSString stringWithFormat:@"备份版本 (%@)", [df stringFromDate:lastBackup]];
    }
    
    UIAction *backupAction = [UIAction actionWithTitle:backupTitle image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self AR_showBackupConfirmation];
    }];
    
    UIMenu *menu = [UIMenu menuWithTitle:@"" children:@[serverAction, localAction, backupAction]];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"获取方式" style:UIBarButtonItemStylePlain target:nil action:nil];
    menuItem.menu = menu;
    self.navigationItem.rightBarButtonItem = menuItem;
}

- (void)AR_showBackupConfirmation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"备份" message:@"备份已安装应用的所有版本" preferredStyle:UIAlertControllerStyleAlert];
    
    CGFloat radius = 25.0;
    CACornerMask mask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    alert.view.layer.cornerRadius = radius;
    alert.view.layer.maskedCorners = mask;
    alert.view.layer.masksToBounds = YES;
    for (UIView *v in alert.view.subviews.firstObject.subviews) {
        v.layer.cornerRadius = radius;
        v.layer.maskedCorners = mask;
        v.layer.masksToBounds = YES;
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"备份" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self AR_startBackupProcess];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)AR_startBackupProcess {
    CGFloat radius = 25.0;
    CACornerMask mask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    
    UIAlertController *loading = [UIAlertController alertControllerWithTitle:@"备份中..." message:@"正在获取版本信息，请勿退出..." preferredStyle:UIAlertControllerStyleAlert];
    loading.view.layer.cornerRadius = radius;
    loading.view.layer.maskedCorners = mask;
    loading.view.layer.masksToBounds = YES;
    for (UIView *v in loading.view.subviews.firstObject.subviews) {
        v.layer.cornerRadius = radius;
        v.layer.maskedCorners = mask;
        v.layer.masksToBounds = YES;
    }
    
    [self presentViewController:loading animated:YES completion:^{
        [[AR_DowngradeManager AR_sharedManager] AR_backupAllAppStoreVersionsWithCompletion:^(NSUInteger successCount, NSUInteger failCount) {
            [loading dismissViewControllerAnimated:YES completion:^{
                [self AR_setupRightMenuButton]; 
                
                NSString *msg = [NSString stringWithFormat:@"成功备份 %lu 个应用，失败 %lu 个。", (unsigned long)successCount, (unsigned long)failCount];
                UIAlertController *doneAlert = [UIAlertController alertControllerWithTitle:@"备份完成" message:msg preferredStyle:UIAlertControllerStyleAlert];
                doneAlert.view.layer.cornerRadius = radius;
                doneAlert.view.layer.maskedCorners = mask;
                doneAlert.view.layer.masksToBounds = YES;
                for (UIView *v in doneAlert.view.subviews.firstObject.subviews) {
                    v.layer.cornerRadius = radius;
                    v.layer.maskedCorners = mask;
                    v.layer.masksToBounds = YES;
                }
                [doneAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:doneAlert animated:YES completion:nil];
            }];
        }];
    }];
}

- (void)AR_arOpenTGChannel {
    NSURL *url = [NSURL URLWithString:OBF("68747470733A2F2F742E6D652F696F7364756D707A7A7A")];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)AR_loadInstalledApps {
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
    
    self.AR_arAllApps = validApps;
    self.AR_arFilteredApps = validApps;
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text.lowercaseString;
    if (searchText.length == 0) {
        self.AR_arFilteredApps = self.AR_arAllApps;
    } else {
        NSMutableArray *results = [NSMutableArray array];
        for (id proxy in self.AR_arAllApps) {
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
        self.AR_arFilteredApps = results;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return self.AR_arFilteredApps.count; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return 1; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = OBF("41707043656C6C"); 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 12.0;
    }
    
    id proxy = self.AR_arFilteredApps[indexPath.section];
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
    id proxy = self.AR_arFilteredApps[indexPath.section];
    
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
    
    AR_VersionViewController *versionVC = [[AR_VersionViewController alloc] init];
    versionVC.AR_bundleID = bundleIdStr; 
    versionVC.AR_appName = name;
    versionVC.AR_appPhysicalPath = fullAppPath; 
    
    [self.navigationController pushViewController:versionVC animated:YES];
}
@end
