// ARDowngradeManager.m
#import "ARDowngradeManager.h"
#import <dlfcn.h>

@interface SKUIItemStateCenter_Private : NSObject
- (id)_newPurchasesWithItems:(NSArray *)items;
- (void)_performPurchases:(id)purchases hasBundlePurchase:(BOOL)purchase withClientContext:(id)context completionBlock:(void(^)(id))block;
@end

@interface ARDowngradeManager ()
- (void)recursiveFetchTrackID:(NSString *)bundleID codes:(NSArray *)codes index:(NSInteger)index completion:(void(^)(long long trackId, NSError *error))completion;
@end

@implementation ARDowngradeManager

+ (instancetype)sharedManager {
    static ARDowngradeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[ARDowngradeManager alloc] init]; });
    return instance;
}

// 🎯 全球 87 个 App Store 国家/地区静默轮询，彻底解决部分应用查无版本问题
- (void)fetchTrackIDForBundleID:(NSString *)bundleID completion:(void(^)(long long, NSError *))completion {
    NSString *countriesStr = OBF("636E2C75732C61652C61672C61692C616C2C616D2C616F2C61722C61742C61752C617A2C62622C62652C62662C62672C62682C626A2C626D2C626E2C626F2C62722C62732C62742C62772C62792C627A2C63612C63672C63682C63692C636C2C636D2C636F2C63722C63762C63792C637A2C64652C646B2C646D2C646F2C647A2C65632C65652C65672C65732C66692C666A2C666D2C66722C67622C67642C67682C676D2C67722C67742C67772C67792C686B2C686E2C68722C68752C69642C69652C696C2C696E2C69732C69742C6A6D2C6A6F2C6A702C6B652C6B672C6B682C6B6E2C6B722C6B772C6B792C6B7A2C6C612C6C622C6C632C6C6B2C6C722C6C742C6C752C6C762C6D642C6D672C6D6B2C6D6C2C6D6E2C6D6F2C6D722C6D732C6D742C6D752C6D752C6D772C6D782C6D792C6E612C6E652C6E672C6E692C6E6C2C6E6F2C6E702C6E7A2C6F6D2C70612C70652C70672C70682C706B2C706C2C70742C70772C70792C71612C726F2C72752C72772C73612C73622C73632C73652C73672C73692C736B2C736C2C736E2C73722C73742C73762C737A2C74632C74642C74682C746A2C746D2C746E2C74722C74742C74772C747A2C75612C75672C75792C757A2C76632C76652C76672C766E2C79652C7A612C7A6D2C7A77");
    NSArray *codes = [countriesStr componentsSeparatedByString:OBF("2C")];
    [self recursiveFetchTrackID:bundleID codes:codes index:0 completion:completion];
}

- (void)recursiveFetchTrackID:(NSString *)bundleID codes:(NSArray *)codes index:(NSInteger)index completion:(void(^)(long long, NSError *))completion {
    if (index >= codes.count) {
        if (completion) completion(0, [NSError errorWithDomain:OBF("417070526574726F") code:404 userInfo:@{NSLocalizedDescriptionKey: OBF("E69CAAE689BEE588B0E5BA94E794A8")}]);
        return;
    }
    NSString *urlFormat = OBF("68747470733A2F2F6974756E65732E6170706C652E636F6D2F6C6F6F6B75703F62756E646C6549643D2540266C696D69743D31266D656469613D736F66747761726526636F756E7472793D2540");
    NSString *urlString = [NSString stringWithFormat:urlFormat, bundleID, codes[index]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            dispatch_async(dispatch_get_main_queue(), ^{ [self recursiveFetchTrackID:bundleID codes:codes index:index+1 completion:completion]; });
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *results = json[OBF("726573756C7473")]; 
        if ([results isKindOfClass:[NSArray class]] && results.count > 0) {
            long long tid = [results.firstObject[OBF("747261636B4964")] longLongValue]; 
            dispatch_async(dispatch_get_main_queue(), ^{ if (completion) completion(tid, nil); });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ [self recursiveFetchTrackID:bundleID codes:codes index:index+1 completion:completion]; });
        }
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
                if (completion) completion(nil, [NSError errorWithDomain:OBF("417070526574726F") code:404 userInfo:@{NSLocalizedDescriptionKey: OBF("E69CAAE7B9A2E68EB7E588B0E58E86E58FB2E78988E69CACE8AEB0E5BD95")}]);
            }
        });
    }];
    [task resume];
}

- (void)verifyOwnershipForBundleID:(NSString *)bundleID appPath:(NSString *)appPath completion:(void(^)(BOOL, NSString *, NSString *, NSArray *))completion {
    void *ssHandle = dlopen([OBF("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F53746F726553657276696365732E6672616D65776F726B2F53746F72655365727669636573") UTF8String], RTLD_LAZY);
    if (!ssHandle || !completion) { if (completion) completion(YES, nil, nil, nil); return; }
    
    Class SSAccountStoreClass = NSClassFromString(OBF("53534163636F756E7453746F7265"));

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id store = [SSAccountStoreClass performSelector:NSSelectorFromString(OBF("64656661756C7453746F7265"))];
    SEL allAccSel = NSSelectorFromString(OBF("616C6C4163636F756E7473"));
    SEL accSel = NSSelectorFromString(OBF("6163636F756E7473"));
    NSArray *accounts = [store respondsToSelector:allAccSel] ? [store performSelector:allAccSel] : [store performSelector:accSel];
#pragma clang diagnostic pop
    
    NSString *activeEmail = nil;
    NSMutableArray *allLocalNames = [NSMutableArray array];
    
    for (id account in accounts) {
        SEL localSel = NSSelectorFromString(OBF("69734C6F63616C4163636F756E74")); 
        BOOL isLocal = NO;
        if ([account respondsToSelector:localSel]) {
            NSMethodSignature *sig = [account methodSignatureForSelector:localSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:account]; 
            [inv setSelector:localSel]; 
            [inv invoke];
            [inv getReturnValue:&isLocal];
        }
        if (isLocal) continue;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString *name = [account performSelector:NSSelectorFromString(OBF("6163636F756E744E616D65"))];
#pragma clang diagnostic pop

        if (name) {
            if ([name.lowercaseString isEqualToString:OBF("6C6F63616C")]) continue;
            [allLocalNames addObject:name];
        }
        
        SEL activeSel = NSSelectorFromString(OBF("6973416374697665")); 
        BOOL isActive = NO;
        if ([account respondsToSelector:activeSel]) {
            NSMethodSignature *sig = [account methodSignatureForSelector:activeSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:account]; 
            [inv setSelector:activeSel]; 
            [inv invoke];
            [inv getReturnValue:&isActive];
        }
        if (isActive) { activeEmail = name; }
    }
    
    NSString *appParentDir = [appPath stringByDeletingLastPathComponent];
    NSString *metadataPath = [appParentDir stringByAppendingPathComponent:OBF("6954756E65734D657461646174612E706C697374")]; 
    NSString *purchaserEmail = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:metadataPath]) {
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:metadataPath];
        NSDictionary *dlInfo = plist[OBF("636F6D2E6170706C652E6954756E657353746F72652E646F776E6C6F6B7570496E666F")] ?: plist[OBF("636F6D2E6170706C652E6954756E657353746F72652E646F776E6C6F6164496E666F")];
        NSDictionary *accInfo = dlInfo[OBF("6163636F756E74496E666F")];
        purchaserEmail = accInfo[OBF("4170706C654944")];
    }
    
    if (!purchaserEmail || !activeEmail) {
        completion(YES, purchaserEmail, activeEmail, allLocalNames); 
        return;
    }
    
    if ([activeEmail caseInsensitiveCompare:purchaserEmail] == NSOrderedSame) {
        completion(YES, purchaserEmail, activeEmail, allLocalNames);
    } else {
        completion(NO, purchaserEmail, activeEmail, allLocalNames); 
    }
}

- (void)executeAccountSwitchToName:(NSString *)targetName {
    Class SSAccountStoreClass = NSClassFromString(OBF("53534163636F756E7453746F7265"));
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id store = [SSAccountStoreClass performSelector:NSSelectorFromString(OBF("64656661756C7453746F7265"))];
    NSArray *accounts = [store performSelector:NSSelectorFromString(OBF("6163636F756E7473"))];
#pragma clang diagnostic pop
    
    id targetAccount = nil;
    for (id account in accounts) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSString *name = [account performSelector:NSSelectorFromString(OBF("6163636F756E744E616D65"))];
#pragma clang diagnostic pop

        if ([name caseInsensitiveCompare:targetName] == NSOrderedSame) {
            targetAccount = account; break;
        }
    }
    if (!targetAccount) return;
    
    SEL setActSel = NSSelectorFromString(OBF("7365744163746976653A"));
    if ([targetAccount respondsToSelector:setActSel]) {
        BOOL val = YES;
        NSMethodSignature *sig = [targetAccount methodSignatureForSelector:setActSel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:targetAccount]; 
        [inv setSelector:setActSel];
        [inv setArgument:&val atIndex:2]; 
        [inv invoke];
    }
    
    NSString *prefStr = OBF("2F7661722F6D6F62696C652F4C6962726172792F507265666572656E6365732F636F6D2E73746F726573776974636865722E6163746976652E747874");
    [targetName writeToFile:prefStr atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    SEL saveSel = NSSelectorFromString(OBF("736176654163636F756E743A76657269667943726564656E7469616C733A6572726F723A"));
    if ([store respondsToSelector:saveSel]) {
        BOOL verify = NO; 
        id __autoreleasing errorOut = nil;
        id __autoreleasing *errPtr = &errorOut;
        NSMethodSignature *sig = [store methodSignatureForSelector:saveSel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:store]; 
        [inv setSelector:saveSel];
        [inv setArgument:&targetAccount atIndex:2];
        [inv setArgument:&verify atIndex:3];
        [inv setArgument:&errPtr atIndex:4]; 
        [inv invoke];
    }
    
    Class SSDeviceClass = NSClassFromString(OBF("5353446576696365"));
    if (SSDeviceClass) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id currentDev = [SSDeviceClass performSelector:NSSelectorFromString(OBF("63757272656E74446576696365"))];
        SEL reloadSel = NSSelectorFromString(OBF("72656C6F616453746F726546726F6E744964656E746966696572"));
        if ([currentDev respondsToSelector:reloadSel]) {
            [currentDev performSelector:reloadSel];
        }
#pragma clang diagnostic pop
    }
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)OBF("636F6D2E73746F7265737769746865722E6163636F756E74735F6368616E676564"), NULL, NULL, YES);
}

- (void)fallbackInstallWithTrackID:(long long)trackId versionID:(long long)versionId {
    // 🎯 1. 确保核心底层库都已加载（StoreServices 与 StoreKitUI）
    void *ssHandle = dlopen([OBF("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F53746F726553657276696365732E6672616D65776F726B2F53746F72655365727669636573") UTF8String], RTLD_LAZY);
    void *skuiHandle = dlopen([OBF("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F53746F72654B697455492E6672616D65776F726B2F53746F72654B69745549") UTF8String], RTLD_LAZY);
    if (!ssHandle || !skuiHandle) return;

    Class SSPurchaseClass = NSClassFromString(OBF("53535075726368617365")); // SSPurchase
    Class SKUIItemStateCenterClass = NSClassFromString(OBF("534B55494974656D537461746543656E746572")); // SKUIItemStateCenter
    
    if (SSPurchaseClass && SKUIItemStateCenterClass) {
        id purchase = [[SSPurchaseClass alloc] init];
        
        NSString *adamId = [NSString stringWithFormat:OBF("256C6C64"), trackId];
        NSString *appExtVrsId = [NSString stringWithFormat:OBF("256C6C64"), versionId];
        NSString *offerString = [NSString stringWithFormat:OBF("70726F64756374547970653D432670726963653D302673616C61626C654164616D49643D25402670726963696E67506172616D65746572733D70726963696E67506172616D657465722661707045787456727349643D254026636C69656E7442757949643D3126696E7374616C6C65643D302674726F6C6C65643D312668617341736B6564546F446F776E6C6F6164557064617465733D31"), adamId, appExtVrsId];

        SEL setBuyParamsSel = NSSelectorFromString(OBF("736574427579506172616D65746572733A"));
        if ([purchase respondsToSelector:setBuyParamsSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [purchase performSelector:setBuyParamsSel withObject:offerString];
#pragma clang diagnostic pop
        }
        
        SEL setUniqueIdSel = NSSelectorFromString(OBF("736574556E697175654964656E7469666965723A"));
        if ([purchase respondsToSelector:setUniqueIdSel]) {
            void (*setUniqueId)(id, SEL, long long) = (void *)[purchase methodForSelector:setUniqueIdSel];
            setUniqueId(purchase, setUniqueIdSel, trackId);
        }

        // 🎯 2. 同步注入与首选方案（ASDPurchase）相同的静默与免验证配置
        NSArray *purchaseBoolSels = @[
            OBF("73657449676E6F726573466F7263656450717373776F72645265737472696374696F6E3A"), // setIgnoresForcedPasswordRestriction:
            OBF("73657450726561757468656E746963617465643A"), // setPreauthenticated:
            OBF("736574536B6970536F6674776172654163636F756E74507265666C696768743A"), // setSkipSoftwareAccountPreflight:
            OBF("736574437265617465734A6F62733A"), // setCreatesJobs:
            OBF("73657443726561746573446F776E6C6F6164733A"), // setCreatesDownloads:
            OBF("736574446973706C6179734F6E4C6F636B53637265656E3A") // setDisplaysOnLockScreen:
        ];
        
        for (NSString *selStr in purchaseBoolSels) {
            SEL s = NSSelectorFromString(selStr);
            if ([purchase respondsToSelector:s]) {
                BOOL val = YES;
                NSMethodSignature *sig = [purchase methodSignatureForSelector:s];
                NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
                [inv setTarget:purchase]; 
                [inv setSelector:s]; 
                [inv setArgument:&val atIndex:2]; 
                [inv invoke];
            }
        }

        // 🎯 3. 终极修复：抛弃会引发 "1060" 无 Observer 崩溃的 SSPurchaseRequest
        // 交由原生自带 Dialog 监听器的 StoreKitUI 直接执行！
        SEL defaultCenterSel = NSSelectorFromString(OBF("64656661756C7443656E746572")); // defaultCenter
        id center = [SKUIItemStateCenterClass performSelector:defaultCenterSel];
        
        if (center) {
            // _performPurchases:hasBundlePurchase:withClientContext:completionBlock:
            SEL performPurchasesSel = NSSelectorFromString(OBF("5F706572666F726D5075726368617365733A68617342756E646C6550757263686173653A77697468436C69656E74436F6E746578743A636F6D706C6574696F6E426C6F636B3A"));
            if ([center respondsToSelector:performPurchasesSel]) {
                NSArray *purchases = @[purchase];
                BOOL hasBundle = NO;
                id clientContext = nil;
                void (^compBlock)(id) = ^(id result) {};
                id copiedBlock = [compBlock copy];
                
                NSMethodSignature *sig = [center methodSignatureForSelector:performPurchasesSel];
                NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
                [inv setTarget:center];
                [inv setSelector:performPurchasesSel];
                [inv setArgument:&purchases atIndex:2];
                [inv setArgument:&hasBundle atIndex:3];
                [inv setArgument:&clientContext atIndex:4];
                [inv setArgument:&copiedBlock atIndex:5];
                [inv retainArguments];
                [inv invoke];
            }
        }
    }
}

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
            
            void (^handlerBlock)(id, NSError*) = ^(id result, NSError *error) {
                NSError *actualError = error;
                if (!actualError && result) {
                    SEL errSel = NSSelectorFromString(OBF("6572726F72"));
                    if ([result respondsToSelector:errSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        actualError = [result performSelector:errSel];
#pragma clang diagnostic pop
                    }
                }
                
                if (actualError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self fallbackInstallWithTrackID:trackId versionID:versionId];
                    });
                }
            };
            id copiedHandler = [handlerBlock copy];
            [inv setArgument:&copiedHandler atIndex:3]; 
            [inv retainArguments];
            [inv invoke];
        }
    } else {
        [self fallbackInstallWithTrackID:trackId versionID:versionId];
    }
}
@end
