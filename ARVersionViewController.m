// ARVersionViewController.m
#import "ARVersionViewController.h"
#import "ARDowngradeManager.h"

@implementation ARVersionViewController

- (instancetype)init {
    UITableViewStyle style = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) style = UITableViewStyleInsetGrouped;
    return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:OBF("254020E9998DE7BAA72FE58D87E7BAA7"), self.appName]; 
    self.tableView.separatorColor = [UIColor clearColor];
    
    // 🎯 修复顶栏不贴合屏幕顶部的问题：针对当前压栈的子页面，确保导航栏底层背景视图底部圆角正确显示
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *barBg = self.navigationController.navigationBar.subviews.firstObject;
        if (barBg) {
            barBg.layer.cornerRadius = 25.0;
            barBg.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
            barBg.layer.masksToBounds = YES;
        }
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return self.versions.count; 
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
    
    NSDictionary *ver = self.versions[indexPath.section];
    NSString *bundleVer = ver[OBF("62756E646C655F76657273696F6E")]; 
    
    cell.textLabel.text = bundleVer ?: OBF("2D");
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.detailTextLabel.text = [ver[OBF("65787465726E616C5F6964656E746966696572")] stringValue];
    
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
    
    NSDictionary *ver = self.versions[indexPath.section];
    long long vId = [ver[OBF("65787465726E616C5F6964656E746966696572")] longLongValue]; 
    NSString *verStr = ver[OBF("62756E646C655F76657273696F6E")];
    
    void (^applyRoundedUI)(UIAlertController *) = ^(UIAlertController *ac) {
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
    };

    [[ARDowngradeManager sharedManager] verifyOwnershipForBundleID:self.bundleID appPath:self.appPhysicalPath completion:^(BOOL isMatch, NSString *purchaser, NSString *active, NSArray *allAccounts) {
        if (isMatch) {
            [self executeDowngradeProcessWithVersionStr:verStr versionID:vId];
        } else {
            NSString *mismatchTitle = OBF("E8B4A6E58FB7E4B88DE58CB9E9858D"); 
            NSString *purchaserText = OBF("E8B4ADE4B9B0E8B4A6E58FB7EFBC9A"); 
            NSString *activeText = OBF("E5BD93E5898DE8B4A6E58FB7EFBC9A"); 
            
            NSString *msg = [NSString stringWithFormat:@"%@\n\n%@ %@\n%@ %@", mismatchTitle, purchaserText, purchaser ?: @"-", activeText, active ?: @"-"];
            UIAlertController *mismatchAlert = [UIAlertController alertControllerWithTitle:OBF("E9AA8CE8AF81E5A4B1E8B4A5") message:msg preferredStyle:UIAlertControllerStyleAlert]; 
            applyRoundedUI(mismatchAlert);
            
            [mismatchAlert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]]; 
            [mismatchAlert addAction:[UIAlertAction actionWithTitle:OBF("E58887E68DA2E8B4A6E58FB7") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { 
                
                UIAlertController *switchSheet = [UIAlertController alertControllerWithTitle:OBF("E98089E68B9CE8B4A6E58FB7") message:purchaser preferredStyle:UIAlertControllerStyleActionSheet]; 
                applyRoundedUI(switchSheet);
                
                for (NSString *accName in allAccounts) {
                    NSString *btnTitle = accName;
                    if ([accName caseInsensitiveCompare:purchaser] == NSOrderedSame) {
                        btnTitle = [NSString stringWithFormat:OBF("2A20E58887E68DA2E588B03A202540"), accName]; 
                    }
                    [switchSheet addAction:[UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
                        
                        UIAlertController *switchingAlert = [UIAlertController alertControllerWithTitle:OBF("E58887E68DA2E4B8ADEFBC8CE7A88DE5908E2E2E2E") message:nil preferredStyle:UIAlertControllerStyleAlert];
                        applyRoundedUI(switchingAlert);
                        [self presentViewController:switchingAlert animated:YES completion:nil];

                        [[ARDowngradeManager sharedManager] executeAccountSwitchToName:accName];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [switchingAlert dismissViewControllerAnimated:YES completion:^{
                                [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                            }];
                        });
                    }]];
                }
                [switchSheet addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:switchSheet animated:YES completion:nil];
            }]];
            
            [self presentViewController:mismatchAlert animated:YES completion:nil];
        }
    }];
}

- (void)executeDowngradeProcessWithVersionStr:(NSString *)verStr versionID:(long long)vId {
    NSString *msg = [NSString stringWithFormat:OBF("2540E7A1AEE8AEA4"), verStr];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:OBF("E7A1AEE8AEA4") message:msg preferredStyle:UIAlertControllerStyleAlert]; 
    
    void (^applyRoundedUI)(UIAlertController *) = ^(UIAlertController *ac) {
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
    };
    applyRoundedUI(alert);
    
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]]; 
    
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E7A1AEE8AEA4") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) { 
        
        [[ARDowngradeManager sharedManager] installAppWithTrackID:self.trackID versionID:vId bundleID:self.bundleID];
        
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
