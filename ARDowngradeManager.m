// ARDowngradeManager.m
#import "ARDowngradeManager.h"
#import <dlfcn.h>

@interface ASDPurchase : NSObject
@property (copy, nonatomic) NSNumber *itemID;
@property (copy, nonatomic) NSString *bundleID;
@property (copy, nonatomic) NSString *buyParameters;
@property (nonatomic, assign) BOOL isRedownload;
@property (nonatomic, assign) BOOL isUpdate;
@property (nonatomic, assign) BOOL isBackgroundUpdate;
@property (nonatomic, assign) BOOL createsJobs;
@property (nonatomic, assign) BOOL displaysOnLockScreen;
@end

@interface ASDPurchaseManager : NSObject
+ (id)sharedManager;
- (void)startPurchase:(id)purchase withResultHandler:(void(^)(id result, NSError *error))handler;
@end

@implementation ARDowngradeManager

+ (instancetype)sharedManager {
    static ARDowngradeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[ARDowngradeManager alloc] init]; });
    return instance;
}

- (void)fetchTrackIDForBundleID:(NSString *)bundleID completion:(void(^)(long long, NSError *))completion {
    // 为保证速度，固定取国区或美区数据
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?bundleId=%@&limit=1&media=software&country=cn", bundleID];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) { if (completion) completion(0, error); return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = json[@"results"];
            if ([results isKindOfClass:[NSArray class]] && results.count > 0) {
                if (completion) completion([results.firstObject[@"trackId"] longLongValue], nil);
            } else {
                if (completion) completion(0, [NSError errorWithDomain:@"Retro" code:404 userInfo:@{NSLocalizedDescriptionKey: @"未找到应用的 Track ID"}]);
            }
        });
    }];
    [task resume];
}

- (void)fetchVersionsForTrackID:(long long)trackId completion:(void(^)(NSArray *, NSError *))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apis.bilin.eu.org/history/%lld", trackId]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) { if (completion) completion(nil, error); return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *versions = json[@"data"];
            if ([versions isKindOfClass:[NSArray class]] && versions.count > 0) {
                if (completion) completion(versions, nil);
            } else {
                if (completion) completion(nil, [NSError errorWithDomain:@"Retro" code:404 userInfo:@{NSLocalizedDescriptionKey: @"未找到历史版本记录"}]);
            }
        });
    }];
    [task resume];
}

- (void)installAppWithTrackID:(long long)trackId versionID:(long long)versionId bundleID:(NSString *)bundleID {
    void *handle = dlopen("/System/Library/PrivateFrameworks/AppStoreDaemon.framework/AppStoreDaemon", RTLD_LAZY);
    if (!handle) return;

    NSString *adamId = [NSString stringWithFormat:@"%lld", trackId];
    NSString *appExtVrsId = [NSString stringWithFormat:@"%lld", versionId];
    NSString *offerString = [NSString stringWithFormat:@"productType=C&price=0&salableAdamId=%@&pricingParameters=pricingParameter&appExtVrsId=%@&clientBuyId=1&installed=0&trolled=1", adamId, appExtVrsId];

    Class ASDPurchaseClass = NSClassFromString(@"ASDPurchase");
    Class ASDPurchaseManagerClass = NSClassFromString(@"ASDPurchaseManager");
        
    if (ASDPurchaseClass && ASDPurchaseManagerClass) {
        ASDPurchase *purchase = [[ASDPurchaseClass alloc] init];
        purchase.itemID = @(trackId);
        purchase.bundleID = bundleID;
        purchase.buyParameters = offerString;
        purchase.isUpdate = YES;
        purchase.isBackgroundUpdate = NO;
        purchase.isRedownload = YES;
        purchase.createsJobs = YES;
        if ([purchase respondsToSelector:@selector(setDisplaysOnLockScreen:)]) {
            purchase.displaysOnLockScreen = YES;
        }

        [[ASDPurchaseManagerClass sharedManager] startPurchase:purchase withResultHandler:^(id result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) NSLog(@"[AppRetro] 下载失败: %@", error);
            });
        }];
    }
}
@end
