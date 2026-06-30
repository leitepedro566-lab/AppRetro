// ARVersionViewController.m
#import "ARVersionViewController.h"
#import "ARDowngradeManager.h"

@interface ARVersionViewController ()
@property (nonatomic, copy) NSString *bundleID;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, assign) long long trackID;
@property (nonatomic, strong) NSArray *versions;
@end

@implementation ARVersionViewController

- (instancetype)init {
    UITableViewStyle style = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) style = UITableViewStyleInsetGrouped;
    return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ Down", self.appName];
    self.tableView.separatorColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.versions.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 1; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = OBF("56657273696F6E43656C6C"); // "VersionCell"
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    NSDictionary *ver = self.versions[indexPath.section];
    NSString *bundleVer = ver[OBF("62756E646C655F76657273696F6E")]; // "bundle_version"
    cell.textLabel.text = bundleVer ?: @"-";
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
            bg.cornerRadius = radius; bg.strokeColor = [UIColor clearColor]; bg.strokeWidth = 0.0;
            cell.backgroundConfiguration = bg;
        }
    }
    if (@available(iOS 13.0, *)) cell.layer.cornerCurve = kCACornerCurveContinuous;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 55.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 5.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 5.0; }
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [UIView new]; }
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { return [UIView new]; }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *ver = self.versions[indexPath.section];
    long long versionId = [ver[OBF("65787465726E616C5F6964656E746966696572")] longLongValue]; 
    NSString *verStr = ver[OBF("62756E646C655F76657273696F6E")];
    
    // "即将开始静默下载安装 v%@..."
    NSString *msg = [NSString stringWithFormat:OBF("E58DB3E5B086E5BC80E5A78BE99D99E9BB98E4B88BE8BDBDE5AE89E8A38520762540EFBC8CE5AE8CE68890E5908EE7B3BBE7BB9FE4BC9AE887AAE58AA8E69BB4E696B0E5AE89E8A385E38082"), verStr];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:OBF("E7A1AEE8AEA4E9998DE7BAA7") // "确认降级"
                                                                   message:msg 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]]; // "取消"
    [alert addAction:[UIAlertAction actionWithTitle:OBF("E5BC80E5A78BE9998DE7BAA7") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) { // "开始降级"
        
        // 1. 静默触发底层购买/更新逻辑
        [[ARDowngradeManager sharedManager] installAppWithTrackID:self.trackID versionID:versionId bundleID:self.bundleID];
        
        // 2. 🎯 核心防闪退修复：延时 0.5s 执行退台，避免阻断 UIAlertController 的 dismiss 动画导致转场断言崩溃！
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            // 已修复错别字：7368617265644170706C69636174696F6E 对应 sharedApplication
            id app = [NSClassFromString(OBF("55494170706C69636174696F6E")) performSelector:NSSelectorFromString(OBF("7368617265644170706C69636174696F6E"))]; 
            SEL suspSel = NSSelectorFromString(OBF("73757370656E64")); // "suspend"
            if ([app respondsToSelector:suspSel]) {
                [app performSelector:suspSel]; // 软件自动完美返回桌面
            }
#pragma clang diagnostic pop
        });
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
