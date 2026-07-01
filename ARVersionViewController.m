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
    [super Xcode_is_not_good];
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:OBF("254020446F776E"), self.appName]; 
    self.tableView.separatorColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.versions.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 1; }

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
    
    // 🎯 公司级最高防线：提交 Daemon 调度队列前，进行购买账号对齐校验，彻底杜绝跨号报错
    [[ARDowngradeManager sharedManager] verifyOwnershipForBundleID:self.bundleID appPath:self.appPhysicalPath completion:^(BOOL isMatch, NSString *purchaser, NSString *active, NSArray *allAccounts) {
        
        if (isMatch) {
            // 账号判定完全相符，直接执行静默降级核心
            [self executeDowngradeProcessWithVersionStr:verStr versionID:vId];
        } else {
            // 判定不相符，拉起高级账号重置面板 (全文字 Hex 编码隐藏)
            NSString *msg = [NSString stringWithFormat:OBF("E8B4A6E58FB7E4B88DE58CB9E9858D200A25400A2540"), purchaser, active];
            UIAlertController *mismatchAlert = [UIAlertController alertControllerWithTitle:OBF("E9AA8CE8AF81E5A4B1E8B4A5") message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            [mismatchAlert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]];
            [mismatchAlert addAction:[UIAlertAction actionWithTitle:OBF("E58887E68DA2E8B4A6E58FB7") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                // 调出设备多账户切换单选栏
                UIAlertController *switchSheet = [UIAlertController alertControllerWithTitle:OBF("E98089E68B9CE8B4A6E58FB7") message:purchaser preferredStyle:UIAlertControllerStyleActionSheet];
                for (NSString *accName in allAccounts) {
                    NSString *btnTitle = accName;
                    if ([accName caseInsensitiveCompare:purchaser] == NSOrderedSame) {
                        btnTitle = [NSString stringWithFormat:OBF("2A20E58887E68DA2E588B03A202540"), accName];
                    }
                    [switchSheet addAction:[UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
                        // 触发 Invocation 换号隔离链
                        [[ARDowngradeManager sharedManager] executeAccountSwitchToName:accName];
                        // 递延 0.4s 后自动重新仿真触发点击重试
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
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
    NSString *msg = [NSString stringWithFormat:OBF("E58DB3E5B086E5BC80E5A78BE99D99E9BB98E4B88BE8BDBDE5AE89E8A38520762540EFBC8CE5AE8CE68890E5908EE7B3BBE7BB9FE4BC9AE887AAE58AA8E69BB4E696B0E5AE89E8A385E38082"), verStr];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:OBF("E7A1AEE8AEA4E9998DE7BAA7") message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E5BC80E5A78BE9998DE7BAA7") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) { 
        
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
