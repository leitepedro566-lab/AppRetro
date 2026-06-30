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
    self.title = [NSString stringWithFormat:@"%@ 降级", self.appName];
    self.tableView.separatorColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.versions.count; // 同样使用单 Section 以形成独立药丸
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VersionCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"VersionCell"];
    }
    
    NSDictionary *ver = self.versions[indexPath.section];
    cell.textLabel.text = [NSString stringWithFormat:@"版本: %@", ver[@"bundle_version"] ?: @"未知"];
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.detailTextLabel.text = [ver[@"external_identifier"] stringValue];
    
    return cell;
}

// 🎯 核心注入：完美的药丸 (Pill) UI 边角处理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat radius = 25.0; // 药丸级圆角
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 5.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 5.0; }
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [UIView new]; }
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { return [UIView new]; }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *ver = self.versions[indexPath.section];
    long long versionId = [ver[@"external_identifier"] longLongValue];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认降级" message:[NSString stringWithFormat:@"即将开始静默下载安装 v%@，完成后系统会自动安装。", ver[@"bundle_version"]] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"开始降级" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[ARDowngradeManager sharedManager] installAppWithTrackID:self.trackID versionID:versionId bundleID:self.bundleID];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
