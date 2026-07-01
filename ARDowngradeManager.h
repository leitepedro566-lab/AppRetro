// ARDowngradeManager.h
#import <Foundation/Foundation.h>

@interface ARDowngradeManager : NSObject
+ (instancetype)sharedManager;
- (void)fetchTrackIDForBundleID:(NSString *)bundleID completion:(void(^)(long long trackId, NSError *error))completion;
- (void)fetchVersionsForTrackID:(long long)trackId completion:(void(^)(NSArray *versions, NSError *error))completion;

// 统一入口，内部自动处理静默优先与弹窗兜底
- (void)installAppWithTrackID:(long long)trackId versionID:(long long)versionId bundleID:(NSString *)bundleID;
@end
