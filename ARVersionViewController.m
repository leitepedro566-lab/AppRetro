// ARVersionViewController.m
#import "ARVersionViewController.h"
#import "ARDowngradeManager.h"

@implementation AR_VersionViewController

- (instancetype)init {
    UITableViewStyle style = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) style = UITableViewStyleInsetGrouped;
    return [super initWithStyle:style];
}

- (void)AR_applyRoundedUIToAlert:(UIAlertController *)ac {
    CGFloat radius = 25.0;
    CACornerMask mask = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    ac.view.layer.cornerRadius = radius;
    ac.view.layer.maskedCorners = mask;
    ac.view.layer.masksToBounds = YES;
    for (UIView *v in ac.view.subviews.firstObject.subviews) {
        v.layer.cornerRadius = radius;
        v.layer.maskedCorners = mask;
        v.layer.masksToBounds = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:OBF("254020E9998DE7BAA72FE58D87E7BAA7"), self.AR_appName]; 
    self.tableView.separatorColor = [UIColor clearColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *barBg = self.navigationController.navigationBar.subviews.firstObject;
        if (barBg) {
            barBg.layer.cornerRadius = 25.0;
            barBg.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
            barBg.layer.masksToBounds = YES;
        }
    });
    
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithTitle:OBF("E887AAE5AE9A") style:UIBarButtonItemStylePlain target:self action:@selector(AR_inputCustomVersion)];
    self.navigationItem.rightBarButtonItem = customItem;
    
    [self AR_fetchVersionData];
}

- (void)AR_fetchVersionData {
    BOOL useLocalBackup = [[NSUserDefaults standardUserDefaults] boolForKey:@"ARUseLocalBackup"];
    
    if (useLocalBackup) {
        NSData *backupData = [[NSUserDefaults standardUserDefaults] objectForKey:@"ARLocalDowngradeBackupData"];
        NSDictionary *backupDict = backupData ? [NSJSONSerialization JSONObjectWithData:backupData options:0 error:nil] : nil;
        NSDictionary *appBackup = backupDict[self.AR_bundleID];
        
        if (appBackup && appBackup[@"versions"]) {
            self.AR_trackID = [appBackup[@"trackId"] longLongValue];
            NSArray *versionsArr = appBackup[@"versions"];
            
            self.AR_versions = [versionsArr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                NSString *date1 = [obj1[OBF("72656C656173655F64617465")] isKindOfClass:[NSString class]] ? obj1[OBF("72656C656173655F64617465")] : @"";
                NSString *date2 = [obj2[OBF("72656C656173655F64617465")] isKindOfClass:[NSString class]] ? obj2[OBF("72656C656173655F64617465")] : @"";
                return [date2 compare:date1];
            }];
            
            [self.tableView reloadData];
        } else {
            UIAlertController *errAlert = [UIAlertController alertControllerWithTitle:@"未找到备份" message:@"未找到该应用的本地版本备份，请先到首页右上角点击“备份全部应用版本”，或切换回“从服务器获取版本”。" preferredStyle:UIAlertControllerStyleAlert];
            [self AR_applyRoundedUIToAlert:errAlert];
            [errAlert addAction:[UIAlertAction actionWithTitle:OBF("E7A1AEE5AE9A") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:errAlert animated:YES completion:nil];
        }
        return;
    }

    UIAlertController *loading = [UIAlertController alertControllerWithTitle:OBF("E7A88DE5908E") message:OBF("E88EB7E58F96E78988E69CACE58897E8A1A82E2E2E") preferredStyle:UIAlertControllerStyleAlert]; 
    [self AR_applyRoundedUIToAlert:loading];
    
    __weak typeof(self) weakSelf = self;
    [self presentViewController:loading animated:YES completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            [loading dismissViewControllerAnimated:NO completion:nil];
            return;
        }
        
        [[AR_DowngradeManager AR_sharedManager] AR_fetchTrackIDForBundleID:strongSelf.AR_bundleID AR_completion:^(long long trackId, NSError *error) {
            __strong typeof(weakSelf) innerSelf1 = weakSelf;
            if (!innerSelf1) {
                dispatch_async(dispatch_get_main_queue(), ^{ [loading dismissViewControllerAnimated:NO completion:nil]; });
                return;
            }
            
            if (error || trackId == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loading dismissViewControllerAnimated:YES completion:^{
                        __strong typeof(weakSelf) innerSelf2 = weakSelf;
                        if (!innerSelf2) return;
                        
                        UIAlertController *errAlert = [UIAlertController alertControllerWithTitle:OBF("E5A4B1E8B4A5") message:error.localizedDescription ?: OBF("E69CAAE689BEE588B0E5BA94E794A8") preferredStyle:UIAlertControllerStyleAlert];
                        [innerSelf2 AR_applyRoundedUIToAlert:errAlert];
                        [errAlert addAction:[UIAlertAction actionWithTitle:OBF("E7A1AEE5AE9A") style:UIAlertActionStyleCancel handler:nil]];
                        [innerSelf2 presentViewController:errAlert animated:YES completion:nil];
                    }];
                });
                return;
            }
            
            innerSelf1.AR_trackID = trackId;
            
            [[AR_DowngradeManager AR_sharedManager] AR_fetchVersionsForTrackID:trackId AR_completion:^(NSArray *versionsArr, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loading dismissViewControllerAnimated:YES completion:^{
                        __strong typeof(weakSelf) innerSelf3 = weakSelf;
                        if (!innerSelf3) return;
                        
                        if (error) {
                            UIAlertController *errAlert = [UIAlertController alertControllerWithTitle:OBF("E5A4B1E8B4A5") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                            [innerSelf3 AR_applyRoundedUIToAlert:errAlert];
                            [errAlert addAction:[UIAlertAction actionWithTitle:OBF("E7A1AEE5AE9A") style:UIAlertActionStyleCancel handler:nil]];
                            [innerSelf3 presentViewController:errAlert animated:YES completion:nil];
                            return;
                        }
                        
                        innerSelf3.AR_versions = [versionsArr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                            NSString *date1 = [obj1[OBF("72656C656173655F64617465")] isKindOfClass:[NSString class]] ? obj1[OBF("72656C656173655F64617465")] : @"";
                            NSString *date2 = [obj2[OBF("72656C656173655F64617465")] isKindOfClass:[NSString class]] ? obj2[OBF("72656C656173655F64617465")] : @"";
                            return [date2 compare:date1];
                        }];
                        
                        [innerSelf3.tableView reloadData];
                    }];
                });
            }];
        }];
    }];
}

- (void)AR_inputCustomVersion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:OBF("E887AAE5AE9A") message:OBF("E8BE93E585A5E78988E69CACE58FB7") preferredStyle:UIAlertControllerStyleAlert]; 
    [self AR_applyRoundedUIToAlert:alert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]]; 
    
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E7A1AEE8AEA4") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { 
        NSString *input = alert.textFields.firstObject.text;
        long long vId = [input longLongValue];
        
        if (vId > 0) {
            if (self.AR_trackID == 0) {
                UIAlertController *err = [UIAlertController alertControllerWithTitle:OBF("E5A4B1E8B4A5") message:OBF("E69CAAE689BEE588B0E5BA94E794A8") preferredStyle:UIAlertControllerStyleAlert];
                [self AR_applyRoundedUIToAlert:err];
                [err addAction:[UIAlertAction actionWithTitle:OBF("E7A1AEE5AE9A") style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:err animated:YES completion:nil];
                return;
            }
            
            [[AR_DowngradeManager AR_sharedManager] AR_verifyOwnershipForBundleID:self.AR_bundleID AR_appPath:self.AR_appPhysicalPath AR_completion:^(BOOL isMatch, NSString *purchaser, NSString *active, NSArray *allAccounts) {
                if (isMatch) {
                    [self AR_executeDowngradeProcessWithVersionStr:input AR_versionID:vId];
                } else {
                    [self AR_handleOwnershipMismatchWithPurchaser:purchaser AR_active:active AR_allAccounts:allAccounts AR_versionStr:input AR_versionID:vId AR_indexPath:nil];
                }
            }];
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return self.AR_versions.count; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return 1; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = OBF("56657273696F6E43656C6C"); 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    NSDictionary *ver = self.AR_versions[indexPath.section];
    NSString *bundleVer = [ver[OBF("62756E646C655F76657273696F6E")] isKindOfClass:[NSString class]] ? ver[OBF("62756E646C655F76657273696F6E")] : OBF("2D");
    
    cell.textLabel.text = bundleVer;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    
    NSString *extIdStr = @"";
    if ([ver[OBF("65787465726E616C5F6964656E746966696572")] isKindOfClass:[NSNumber class]] || [ver[OBF("65787465726E616C5F6964656E746966696572")] isKindOfClass:[NSString class]]) {
        extIdStr = [NSString stringWithFormat:@"%@", ver[OBF("65787465726E616C5F6964656E746966696572")]];
    }
    cell.detailTextLabel.text = extIdStr;
    
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
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 55.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 5.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 5.0; }
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [UIView new]; }
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { return [UIView new]; }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *ver = self.AR_versions[indexPath.section];
    long long vId = [ver[OBF("65787465726E616C5F6964656E746966696572")] longLongValue]; 
    NSString *verStr = [ver[OBF("62756E646C655F76657273696F6E")] isKindOfClass:[NSString class]] ? ver[OBF("62756E646C655F76657273696F6E")] : OBF("2D");
    
    [[AR_DowngradeManager AR_sharedManager] AR_verifyOwnershipForBundleID:self.AR_bundleID AR_appPath:self.AR_appPhysicalPath AR_completion:^(BOOL isMatch, NSString *purchaser, NSString *active, NSArray *allAccounts) {
        if (isMatch) {
            [self AR_executeDowngradeProcessWithVersionStr:verStr AR_versionID:vId];
        } else {
            [self AR_handleOwnershipMismatchWithPurchaser:purchaser AR_active:active AR_allAccounts:allAccounts AR_versionStr:verStr AR_versionID:vId AR_indexPath:indexPath];
        }
    }];
}

- (void)AR_handleOwnershipMismatchWithPurchaser:(NSString *)purchaser AR_active:(NSString *)active AR_allAccounts:(NSArray *)allAccounts AR_versionStr:(NSString *)verStr AR_versionID:(long long)vId AR_indexPath:(NSIndexPath *)indexPath {
    NSString *mismatchTitle = OBF("E8B4A6E58FB7E4B88DE58CB9E9858D"); 
    NSString *purchaserText = OBF("E8B4ADE4B9B0E8B4A6E58FB7EFBC9A"); 
    NSString *activeText = OBF("E5BD93E5898DE8B4A6E58FB7EFBC9A"); 
    
    NSString *msg = [NSString stringWithFormat:@"%@\n\n%@ %@\n%@ %@", mismatchTitle, purchaserText, purchaser ?: @"-", activeText, active ?: @"-"];
    UIAlertController *mismatchAlert = [UIAlertController alertControllerWithTitle:OBF("E9AA8CE8AF81E5A4B1E8B4A5") message:msg preferredStyle:UIAlertControllerStyleAlert]; 
    [self AR_applyRoundedUIToAlert:mismatchAlert];
    
    [mismatchAlert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]]; 
    [mismatchAlert addAction:[UIAlertAction actionWithTitle:OBF("E58887E68DA2E8B4A6E58FB7") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { 
        
        UIAlertController *switchSheet = [UIAlertController alertControllerWithTitle:OBF("E98089E68B9CE8B4A6E58FB7") message:purchaser preferredStyle:UIAlertControllerStyleActionSheet]; 
        [self AR_applyRoundedUIToAlert:switchSheet];
        
        for (NSString *accName in allAccounts) {
            NSString *btnTitle = accName;
            if ([accName caseInsensitiveCompare:purchaser] == NSOrderedSame) {
                btnTitle = [NSString stringWithFormat:OBF("2A20E58887E68DA2E588B03A202540"), accName]; 
            }
            [switchSheet addAction:[UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
                
                UIAlertController *switchingAlert = [UIAlertController alertControllerWithTitle:OBF("E58887E68DA2E4B8ADEFBC8CE7A88DE5908E2E2E2E") message:nil preferredStyle:UIAlertControllerStyleAlert]; 
                [self AR_applyRoundedUIToAlert:switchingAlert];
                [self presentViewController:switchingAlert animated:YES completion:nil];

                [[AR_DowngradeManager AR_sharedManager] AR_executeAccountSwitchToName:accName];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [switchingAlert dismissViewControllerAnimated:YES completion:^{
                        if (indexPath) {
                            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                        } else {
                            [self AR_executeDowngradeProcessWithVersionStr:verStr AR_versionID:vId];
                        }
                    }];
                });
            }]];
        }
        [switchSheet addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:switchSheet animated:YES completion:nil];
    }]];
    
    [self presentViewController:mismatchAlert animated:YES completion:nil];
}

- (void)AR_executeDowngradeProcessWithVersionStr:(NSString *)verStr AR_versionID:(long long)vId {
    NSString *msg = [NSString stringWithFormat:OBF("2540E7A1AEE8AEA4"), verStr];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:OBF("E7A1AEE8AEA4") message:msg preferredStyle:UIAlertControllerStyleAlert]; 
    [self AR_applyRoundedUIToAlert:alert];
    
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]]; 
    
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E7A1AEE8AEA4") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) { 
        
        [[AR_DowngradeManager AR_sharedManager] AR_installAppWithTrackID:self.AR_trackID AR_versionID:vId AR_bundleID:self.AR_bundleID];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id app = [NSClassFromString(OBF("55494170706C69636174696F6E")) performSelector:NSSelectorFromString(OBF("7368617265644170706C69636174696F6E"))]; 
            SEL suspSel = NSSelectorFromString(OBF("73757370656E64")); 
            if ([app respondsToSelector:suspSel]) {
                [app performSelector:suspSel]; 
            }
#pragma clang diagnostic pop
        });
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
