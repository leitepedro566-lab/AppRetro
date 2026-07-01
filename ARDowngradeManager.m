// ARDowngradeManager.m
#import "ARDowngradeManager.h"
#import <dlfcn.h>
#import "Obfuscation.h"

@implementation ARDowngradeManager

+ (instancetype)sharedManager {
    static ARDowngradeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[ARDowngradeManager alloc] init]; });
    return instance;
}

- (void)fetchTrackIDForBundleID:(NSString *)bundleID completion:(void(^)(long long, NSError *))completion {
    NSString *urlFormat = OBF("68747470733A2F2F6974756E65732E6170706C652E636F6D2F6C6F6F6B75703F62756E646C6549643D2540266C696D69743D31266D656469613D736F66747761726526636F756E7472793D636E");
    NSString *urlString = [NSString stringWithFormat:urlFormat, bundleID];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) { if (completion) completion(0, error); return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = json[OBF("726573756C7473")]; 
            if ([results isKindOfClass:[NSArray class]] && results.count > 0) {
                if (completion) completion([results.firstObject[OBF("747261636B4964")] longLongValue], nil); 
            } else {
                if (completion) completion(0, [NSError errorWithDomain:OBF("526574726F") code:404 userInfo:@{NSLocalizedDescriptionKey: OBF("E69CAAE7B9A2E68EB7E588B0E5BA94E794A820547261636B204944")}]);
            }
        });
    }];
    [task resume];
}

- (void)fetchVersionsForTrackID:(long long)trackId completion:(void(^)(NSArray *, NSError *))completion {
    NSString *urlFormat = OBF("68747470733A2F2F617069732E62696C696E2E65752E6F72672F686973746F72792F256C6C64");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, trackId]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) { if (completion) completion(nil, error); return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *versionsArr = json[OBF("64617461")]; 
            if ([versionsArr isKindOfClass:[NSArray class]] && versionsArr.count > 0) {
                 if (completion) completion(versionsArr, nil);
            } else {
                if (completion) completion(nil, [NSError errorWithDomain:OBF("526574726F") code:404 userInfo:@{NSLocalizedDescriptionKey: OBF("E69CAAE7B9A2E68EB7E588B0E58E86E58FB2E78988E69CACE8AEB0E5BD95")}]);
            }
        });
    }];
    [task resume];
}

// 🎯 兜底防线：遇到更高系统版本限制、无法静默时，自动拉起 StoreKitUI 前端
- (void)fallbackInstallWithTrackID:(long long)trackId versionID:(long long)versionId {
    NSString *skuiPath = OBF("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F53746F72654B697455492E6672616D65776F726B2F53746F72654B69745549");
    void *handle = dlopen([skuiPath UTF8String], RTLD_LAZY);
    if (!handle) return;

    NSString *adamId = [NSString stringWithFormat:OBF("256C6C64"), trackId];
    NSString *appExtVrsId = [NSString stringWithFormat:OBF("256C6C64"), versionId];
    NSString *offerString = [NSString stringWithFormat:OBF("70726F64756374547970653D432670726963653D302673616C61626C654164616D49643D25402670726963696E67506172616D65746572733D70726963696E67506172616D657465722661707045787456727349643D254026636C69656E7442757949643D3126696E7374616C6C65643D302674726F6C6C65643D31"), adamId, appExtVrsId];

    NSDictionary *offerDict = @{OBF("627579506172616D73"): offerString}; 
    NSDictionary *itemDict = @{OBF("5F6974656D4F66666572"): adamId}; 

    Class SKUIItemOfferClass = NSClassFromString(OBF("534B55494974656D4F66666572"));
    Class SKUIItemClass = NSClassFromString(OBF("534B55494974656D"));
    Class SKUIItemStateCenterClass = NSClassFromString(OBF("534B55494974656D537461746543656E746572"));
    Class SKUIClientContextClass = NSClassFromString(OBF("534B5549436C69656E74436F6E74657874"));

    if (SKUIItemOfferClass && SKUIItemClass && SKUIItemStateCenterClass) {
        id offer = [SKUIItemOfferClass alloc];
        id item = [SKUIItemClass alloc];
        SEL initSel = NSSelectorFromString(OBF("696E6974576974684C6F6F6B757044696374696F6E6172793A"));
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        offer = [offer performSelector:initSel withObject:offerDict];
        item = [item performSelector:initSel withObject:itemDict];
#pragma clang diagnostic pop

        if (!item) return;

        [item setValue:offer forKey:OBF("5F6974656D4F66666572")]; 
        [item setValue:OBF("696F73536F667477617265") forKey:OBF("5F6974656D4B696E64537472696E67")]; 
        [item setValue:@(versionId) forKey:OBF("5F76657273696F6E4964656E746966696572")]; 

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id center = [SKUIItemStateCenterClass performSelector:NSSelectorFromString(OBF("64656661756C7443656E746572"))]; 
        id context = [SKUIClientContextClass performSelector:NSSelectorFromString(OBF("64656661756C74436F6E74657874"))]; 
        NSArray *items = @[item];
        id purchases = [center performSelector:NSSelectorFromString(OBF("5F6E6577507572636861736573576974684974656D733A")) withObject:items]; 
#pragma clang diagnostic pop

        SEL performSel = NSSelectorFromString(OBF("5F706572666F726D5075726368617365733A68617342756E646C6550757263686173653A77697468436C69656E74436F6E746578743A636F6D706C6574696F6E426C6F636B3A"));
        if ([center respondsToSelector:performSel]) {
            NSMethodSignature *sig = [center methodSignatureForSelector:performSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:center];
            [inv setSelector:performSel];
            [inv setArgument:&purchases atIndex:2];
            BOOL hasBundle = NO;
            [inv setArgument:&hasBundle atIndex:3];
            [inv setArgument:&context atIndex:4];
            void (^block)(id) = ^(id arg1){};
            [inv setArgument:&block atIndex:5];
            [inv invoke];
        }
    }
}

// 🎯 主力方案：AppStoreDaemon 暴力静默下载 (直接绕过验证逻辑)
- (void)installAppWithTrackID:(long long)trackId versionID:(long long)versionId bundleID:(NSString *)bundleID {
    NSString *daemonPath = OBF("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F41707053746F72654461656D6F6E2E6672616D65776F726B2F41707053746F72654461656D6F6E");
    void *handle = dlopen([daemonPath UTF8String], RTLD_LAZY);
    if (!handle) {
        [self fallbackInstallWithTrackID:trackId versionID:versionId];
        return;
    }

    NSString *adamId = [NSString stringWithFormat:OBF("256C6C64"), trackId];
    NSString *appExtVrsId = [NSString stringWithFormat:OBF("256C6C64"), versionId];
    
    NSString *offerString = [NSString stringWithFormat:OBF("70726F64756374547970653D432670726963653D302673616C61626C654164616D49643D25402670726963696E67506172616D65746572733D70726963696E67506172616D657465722661707045787456727349643D254026636C69656E7442757949643D3126696E7374616C6C65643D302674726F6C6C65643D31"), adamId, appExtVrsId];

    Class ASDPurchaseClass = NSClassFromString(OBF("4153445075726368617365"));
    Class ASDPurchaseManagerClass = NSClassFromString(OBF("41534450757263686173654D616E61676572"));
        
    if (ASDPurchaseClass && ASDPurchaseManagerClass) {
        id purchase = [[ASDPurchaseClass alloc] init];
        [purchase setValue:@(trackId) forKey:OBF("6974656D4944")]; 
        [purchase setValue:bundleID forKey:OBF("62756E646C654944")]; 
        [purchase setValue:offerString forKey:OBF("627579506172616D6574657273")]; 
        
        // 关键静默降级核心：定性为 更新，并关闭 BackgroundWait 强制拉起
        [purchase setValue:@(YES) forKey:OBF("6973557064617465")]; 
        [purchase setValue:@(NO) forKey:OBF("69734261636B67726F756E64557064617465")]; 
        [purchase setValue:@(YES) forKey:OBF("69735265646F776E6C6F6164")]; 
        [purchase setValue:@(YES) forKey:OBF("637265617465734A6F6273")]; 
        
        SEL dispSel = NSSelectorFromString(OBF("736574446973706C6179734F6E4C6F636B53637265656E3A"));
        if ([purchase respondsToSelector:dispSel]) {
            BOOL val = YES;
            NSMethodSignature *sig = [purchase methodSignatureForSelector:dispSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:purchase]; 
            [inv setSelector:dispSel]; 
            [inv setArgument:&val atIndex:2]; 
            [inv invoke];
        }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id mgr = [ASDPurchaseManagerClass performSelector:NSSelectorFromString(OBF("7368617265644D616E61676572"))]; 
#pragma clang diagnostic pop
        
        SEL startSel = NSSelectorFromString(OBF("737461727450757263686173653A77697468526573756C7448616E646C65723A"));
        if ([mgr respondsToSelector:startSel]) {
            NSMethodSignature *sig = [mgr methodSignatureForSelector:startSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:mgr]; 
            [inv setSelector:startSel]; 
            [inv setArgument:&purchase atIndex:2];
            
            // 🎯 【智能回退】静默守护进程报错 (比如触发高版本系统兼容性拒绝)，立刻调用兜底方案弹窗
            void (^handler)(id, NSError*) = ^(id result, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self fallbackInstallWithTrackID:trackId versionID:versionId];
                    });
                }
            };
            [inv setArgument:&handler atIndex:3]; 
            [inv invoke];
        }
    } else {
        [self fallbackInstallWithTrackID:trackId versionID:versionId];
    }
}
@end
