// ARDowngradeManager.m
#import "ARDowngradeManager.h"
#import <dlfcn.h>

@implementation ARDowngradeManager

+ (instancetype)sharedManager {
    static ARDowngradeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[ARDowngradeManager alloc] init]; });
    return instance;
}

- (void)fetchTrackIDForBundleID:(NSString *)bundleID completion:(void(^)(long long, NSError *))completion {
    // URL: https://itunes.apple.com/lookup?bundleId=%@&limit=1&media=software&country=cn
    NSString *urlFormat = OBF("68747470733A2F2F6974756E65732E6170706C652E636F6D2F6C6F6F6B75703F62756E646C6549643D2540266C696D69743D31266D656469613D736F66747761726526636F756E7472793D636E");
    NSString *urlString = [NSString stringWithFormat:urlFormat, bundleID];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) { if (completion) completion(0, error); return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = json[OBF("726573756C7473")]; // "results"
            if ([results isKindOfClass:[NSArray class]] && results.count > 0) {
                if (completion) completion([results.firstObject[OBF("747261636B4964")] longLongValue], nil); 
            } else {
                if (completion) completion(0, [NSError errorWithDomain:@"Retro" code:404 userInfo:@{NSLocalizedDescriptionKey: @"未找到应用的 Track ID"}]);
            }
        });
    }];
    [task resume];
}

- (void)fetchVersionsForTrackID:(long long)trackId completion:(void(^)(NSArray *, NSError *))completion {
    // URL: https://apis.bilin.eu.org/history/%lld
    NSString *urlFormat = OBF("68747470733A2F2F617069732E62696C696E2E65752E6F72672F686973746F72792F256C6C64");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, trackId]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) { if (completion) completion(nil, error); return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *versions = json[OBF("64617461")]; // "data"
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
    // 路径解密: /System/Library/PrivateFrameworks/AppStoreDaemon.framework/AppStoreDaemon
    NSString *daemonPath = OBF("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F41707053746F72654461656D6F6E2E6672616D65776F726B2F41707053746F72654461656D6F6E");
    void *handle = dlopen([daemonPath UTF8String], RTLD_LAZY);
    if (!handle) return;

    NSString *adamId = [NSString stringWithFormat:@"%lld", trackId];
    NSString *appExtVrsId = [NSString stringWithFormat:@"%lld", versionId];
    NSString *offerString = [NSString stringWithFormat:@"productType=C&price=0&salableAdamId=%@&pricingParameters=pricingParameter&appExtVrsId=%@&clientBuyId=1&installed=0&trolled=1", adamId, appExtVrsId];

    // ASDPurchase & ASDPurchaseManager
    Class ASDPurchaseClass = NSClassFromString(OBF("4153445075726368617365"));
    Class ASDPurchaseManagerClass = NSClassFromString(OBF("41534450757263686173654D616E61676572"));
        
    if (ASDPurchaseClass && ASDPurchaseManagerClass) {
        id purchase = [[ASDPurchaseClass alloc] init];
        [purchase setValue:@(trackId) forKey:OBF("6974656D4944")]; // itemID
        [purchase setValue:bundleID forKey:OBF("62756E646C654944")]; // bundleID
        [purchase setValue:offerString forKey:OBF("627579506172616D6574657273")]; // buyParameters
        [purchase setValue:@(YES) forKey:OBF("6973557064617465")]; // isUpdate
        [purchase setValue:@(NO) forKey:OBF("69734261636B67726F756E64557064617465")]; // isBackgroundUpdate
        [purchase setValue:@(YES) forKey:OBF("69735265646F776E6C6F6164")]; // isRedownload
        [purchase setValue:@(YES) forKey:OBF("637265617465734A6F6273")]; // createsJobs
        
        // 动态隐藏调用 displaysOnLockScreen
        SEL dispSel = NSSelectorFromString(OBF("736574446973706C6179734F6E4C6F636B53637265656E3A"));
        if ([purchase respondsToSelector:dispSel]) {
            BOOL val = YES;
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[purchase methodSignatureForSelector:dispSel]];
            [inv setTarget:purchase];
            [inv setSelector:dispSel];
            [inv setArgument:&val atIndex:2];
            [inv invoke];
        }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // 获取单例 sharedManager
        id mgr = [ASDPurchaseManagerClass performSelector:NSSelectorFromString(OBF("7368617265644D616E61676572"))]; 
#pragma clang diagnostic pop
        
        // 🎯 动态隐藏核心下载 API: startPurchase:withResultHandler:
        SEL startSel = NSSelectorFromString(OBF("737461727450757263686173653A77697468526573756C7448616E646C65723A"));
        if ([mgr respondsToSelector:startSel]) {
            NSMethodSignature *sig = [mgr methodSignatureForSelector:startSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:mgr];
            [inv setSelector:startSel];
            [inv setArgument:&purchase atIndex:2];
            
            void (^handler)(id, NSError*) = ^(id result, NSError *error) {
                if (error) NSLog(@"[AppRetro] Err: %@", error);
            };
            [inv setArgument:&handler atIndex:3];
            [inv invoke];
        }
    }
}
@end
