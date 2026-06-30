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
    self.title = [NSString stringWithFormat:@"%@ Down", self.appName];
    self.tableView.separatorColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.versions.count; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = HEX_DEC("56657273696F6E43656C6C"); // "VersionCell"
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    NSDictionary *ver = self.versions[indexPath.section];
    NSString *bundleVer = ver[HEX_DEC("62756E646C655F76657273696F6E")]; // "bundle_version"
    cell.textLabel.text = bundleVer ?: @"-";
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.detailTextLabel.text = [ver[HEX_DEC("65787465726E616C5F6964656E746966696572")] stringValue]; // "external_identifier"
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { return 55.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { return 5.0; }
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { return 5.0; }
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { return [UIView new]; }
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section { return [UIView new]; }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *ver = self.versions[indexPath.section];
    long long versionId = [ver[HEX_DEC("65787465726E616C5F6964656E746966696572")] longLongValue]; // "external_identifier"
    NSString *verStr = ver[HEX_DEC("62756E646C655F76657273696F6E")];
    
    NSString *msg = [NSString stringWithFormat:HEX_DEC("E58DB3E5B086E5BC80E5A78BE99D99E9BB98E4B88BE8BDBDE5AE89E8A38520762540EFBC8CE5AE8CE68890E5908EE7B3BBE7BB9FE4BC9AE887AAE58AA8E5AE89E8A385E38082"), verStr]; // "即将开始静默下载安装 v%@..."
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:HEX_DEC("E7A1AEE8AEA4E9998DE7BAA7") // "确认降级"
                                                                   message:msg 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:HEX_DEC("E58F96E6B688") style:UIAlertActionStyleCancel handler:nil]]; // "取消"
    [alert addAction:[UIAlertAction actionWithTitle:HEX_DEC("E5BC80E5A78BE9998DE7BAA7") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) { // "开始降级"
        [[ARDowngradeManager sharedManager] installAppWithTrackID:self.trackID versionID:versionId bundleID:self.bundleID];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
