// ARDowngradeManager.h
#import <Foundation/Foundation.h>

__attribute__((visibility("hidden"))) __attribute__((objc_subclassing_restricted))
@interface AR_DowngradeManager : NSObject

+ (instancetype)AR_sharedManager;

// 🎯 所有自定义方法全部加前缀，让宏彻底接管方法签名
- (void)AR_fetchTrackIDForBundleID:(NSString *)AR_bundleID AR_completion:(void(^)(long long AR_trackID, NSError *error))AR_completion;
- (void)AR_fetchVersionsForTrackID:(long long)AR_trackID AR_completion:(void(^)(NSArray *AR_versions, NSError *error))AR_completion;
- (void)AR_installAppWithTrackID:(long long)AR_trackID AR_versionID:(long long)AR_versionID AR_bundleID:(NSString *)AR_bundleID;

- (void)AR_verifyOwnershipForBundleID:(NSString *)AR_bundleID AR_appPath:(NSString *)AR_appPath AR_completion:(void(^)(BOOL isMatch, NSString *purchaser, NSString *AR_active, NSArray *AR_allAccounts))AR_completion;
- (void)AR_executeAccountSwitchToName:(NSString *)targetName;

- (void)AR_backupAllAppStoreVersionsWithCompletion:(void(^)(NSUInteger successCount, NSUInteger failCount))AR_completion;

@end
