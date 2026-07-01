// ARDowngradeManager.h
#import <Foundation/Foundation.h>

@interface ARDowngradeManager : NSObject
+ (instancetype)sharedManager;
- (void)fetchTrackIDForBundleID:(NSString *)bundleID completion:(void(^)(long long trackId, NSError *error))completion;
- (void)fetchVersionsForTrackID:(long long)trackId completion:(void(^)(NSArray *versions, NSError *error))completion;
- (void)installAppWithTrackID:(long long)trackId versionID:(long long)versionId bundleID:(NSString *)bundleID;

// 新增：账号合规验证与一键安全换号控制层接口
- (void)verifyOwnershipForBundleID:(NSString *)bundleID appPath:(NSString *)appPath completion:(void(^)(BOOL isMatch, NSString *purchaser, NSString *active, NSArray *allAccounts))completion;
- (void)executeAccountSwitchToName:(NSString *)targetName;
@end
