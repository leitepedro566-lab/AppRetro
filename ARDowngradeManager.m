// ARDowngradeManager.m
#import "ARDowngradeManager.h"
#import <dlfcn.h>
// 头文件已经被 Makefile 全局 include，可以直接使用 HEX_DEC

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
    // 解密 URL: https://itunes.apple.com/lookup?bundleId=%@&limit=1&media=software&country=cn
    NSString *urlFormat = HEX_DEC("68747470733A2F2F6974756E65732E6170706C652E636F6D2F6C6F6F6B75703F62756E646C6549643D2540266C696D69743D31266D656469613D736F66747761726526636F756E7472793D636E");
    NSString *urlString = [NSString stringWithFormat:urlFormat, bundleID];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) { if (completion) completion(0, error); return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = json[HEX_DEC("726573756C7473")]; // "results"
            if ([results isKindOfClass:[NSArray class]] && results.count > 0) {
                if (completion) completion([results.firstObject[HEX_DEC("747261636B4964")] longLongValue], nil); // "trackId"
            } else {
                if (completion) completion(0, [NSError errorWithDomain:@"Retro" code:404 userInfo:@{NSLocalizedDescriptionKey: @"未找到应用的 Track ID"}]);
            }
        });
    }];
    [task resume];
}

- (void)fetchVersionsForTrackID:(long long)trackId completion:(void(^)(NSArray *, NSError *))completion {
    // 解密 URL: https://apis.bilin.eu.org/history/%lld
    NSString *urlFormat = HEX_DEC("68747470733A2F2F617069732E62696C696E2E65752E6F72672F686973746F72792F256C6C64");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, trackId]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) { if (completion) completion(nil, error); return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *versions = json[HEX_DEC("64617461")]; // "data"
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
    // 解密路径: /System/Library/PrivateFrameworks/AppStoreDaemon.framework/AppStoreDaemon
    NSString *daemonPath = HEX_DEC("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F41707053746F72654461656D6F6E2E6672616D65776F726B2F41707053746F72654461656D6F6E");
    void *handle = dlopen([daemonPath UTF8String], RTLD_LAZY);
    if (!handle) return;

    NSString *adamId = [NSString stringWithFormat:@"%lld", trackId];
    NSString *appExtVrsId = [NSString stringWithFormat:@"%lld", versionId];
    NSString *offerString = [NSString stringWithFormat:@"productType=C&price=0&salableAdamId=%@&pricingParameters=pricingParameter&appExtVrsId=%@&clientBuyId=1&installed=0&trolled=1", adamId, appExtVrsId];

    // 解密类名: ASDPurchase & ASDPurchaseManager
    Class ASDPurchaseClass = NSClassFromString(HEX_DEC("4153445075726368617365"));
    Class ASDPurchaseManagerClass = NSClassFromString(HEX_DEC("41534450757263686173654D616E61676572"));
        
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
