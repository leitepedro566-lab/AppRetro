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
    
    self.title = [NSString stringWithFormat:OBF("254020446F776E"), self.appName]; 
    self.tableView.separatorColor = [UIColor clearColor];
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
    
    SEL verifySel = NSSelectorFromString(OBF("7665726966794F776E657273686970466F7242756E646C6549443A617070506174683A636F6D706C6574696F6E3A"));
    
    if ([[ARDowngradeManager sharedManager] respondsToSelector:verifySel]) {
        void (^verifyBlock)(BOOL, NSString *, NSString *, NSArray *) = ^(BOOL isMatch, NSString *purchaser, NSString *active, NSArray *allAccounts) {
            
            if (isMatch) {
                [self executeDowngradeProcessWithVersionStr:verStr versionID:vId];
            } else {
                // 🎯 优化 UI 呈现与文字，全部 Hex 化
                NSString *mismatchTitle = OBF("E8B4A6E58FB7E4B88DE58CB9"); // "账号不匹配"
                NSString *purchaserText = OBF("E8B4ADE4B9B0E8B4A6E58FB7EFBC9A"); // "购买账号："
                NSString *activeText = OBF("E5BD93E5898DE8B4A6E58FB7EFBC9A"); // "当前账号："
                
                NSString *msg = [NSString stringWithFormat:@"%@\n\n%@ %@\n%@ %@", mismatchTitle, purchaserText, purchaser, activeText, active];
                UIAlertController *mismatchAlert = [UIAlertController alertControllerWithTitle:OBF("E9AA8CE8AF81E5A4B1E8B4A5") message:msg preferredStyle:UIAlertControllerStyleAlert]; 
                
                [mismatchAlert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]]; 
                [mismatchAlert addAction:[UIAlertAction actionWithTitle:OBF("E58887E68DA2E8B4A6E58FB7") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { 
                    
                    UIAlertController *switchSheet = [UIAlertController alertControllerWithTitle:OBF("E98089E68B9CE8B4A6E58FB7") message:purchaser preferredStyle:UIAlertControllerStyleActionSheet]; 
                    
                    for (NSString *accName in allAccounts) {
                        NSString *btnTitle = accName;
                        if ([accName caseInsensitiveCompare:purchaser] == NSOrderedSame) {
                            btnTitle = [NSString stringWithFormat:OBF("2A20E58887E68DA2E588B03A202540"), accName]; 
                        }
                        [switchSheet addAction:[UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
                            
                            // 🎯 弹出阻断型交互，提示系统正在切换
                            UIAlertController *switchingAlert = [UIAlertController alertControllerWithTitle:OBF("E58887E68DA2E4B8ADEFBC8CE8AFB7E7A88DE580992E2E2E") message:nil preferredStyle:UIAlertControllerStyleAlert]; // "切换中，请稍候..."
                            [self presentViewController:switchingAlert animated:YES completion:nil];

                            SEL switchSel = NSSelectorFromString(OBF("657865637574654163636F756E74537769746368546F4E616D653A"));
                            if ([[ARDowngradeManager sharedManager] respondsToSelector:switchSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                                [[ARDowngradeManager sharedManager] performSelector:switchSel withObject:accName];
#pragma clang diagnostic pop
                            }
                            
                            // 🎯 核心延迟调参：将 0.4s 修改为更安全的 1.2s，保证 Daemon 后台数据库彻底刷新，不再循环报错
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
        };
        
        NSMethodSignature *sig = [[[ARDowngradeManager sharedManager] class] instanceMethodSignatureForSelector:verifySel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:[ARDowngradeManager sharedManager]];
        [inv setSelector:verifySel];
        
        NSString *tempBundle = self.bundleID;
        NSString *tempPath = self.appPhysicalPath;
        
        [inv setArgument:&tempBundle atIndex:2];
        [inv setArgument:&tempPath atIndex:3];
        [inv setArgument:&verifyBlock atIndex:4];
        [inv invoke];
    } else {
        [self executeDowngradeProcessWithVersionStr:verStr versionID:vId];
    }
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
