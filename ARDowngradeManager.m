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
                if (completion) completion(0, [NSError errorWithDomain:@"Retro" code:404 userInfo:@{NSLocalizedDescriptionKey: OBF("E69CAAE7B9A2E68EB7E588B0E5BA94E794A820547261636B204944")}]);
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
                if (completion) completion(nil, [NSError errorWithDomain:@"Retro" code:404 userInfo:@{NSLocalizedDescriptionKey: OBF("E69CAAE7B9A2E68EB7E588B0E58E86E58FB2E78988E69CACE8AEB0E5BD95")}]);
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

        if (name) [allLocalNames addObject:name];
        
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
        BOOL verify = NO; id errorOut = nil;
        NSMethodSignature *sig = [store methodSignatureForSelector:saveSel];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:store]; 
        [inv setSelector:saveSel];
        [inv setArgument:&targetAccount atIndex:2];
        [inv setArgument:&verify atIndex:3];
        [inv setArgument:&errorOut atIndex:4]; 
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
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)OBF("636F6D2E73746F726573776974636865722E6163636F756E74735F6368616E676564"), NULL, NULL, YES);
}

// 🎯 降级方案二 (兜底): StoreKitUI - 带有前端界面弹窗支持 (能接住iOS系统过低弹窗)
- (void)fallbackInstallWithTrackID:(long long)trackId versionID:(long long)versionId {
    NSString *skuiPath = OBF("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F53746F72654B697455492E6672616D65776F726B2F53746F72654B69745549");
    void *handle = dlopen([skuiPath UTF8String], RTLD_LAZY);
    if (!handle) return;

    NSString *adamId = [NSString stringWithFormat:@"%lld", trackId];
    NSString *appExtVrsId = [NSString stringWithFormat:@"%lld", versionId];
    
    NSString *offerString = [NSString stringWithFormat:OBF("70726F64756374547970653D432670726963653D302673616C61626C654164616D49643D25402670726963696E67506172616D65746572733D70726963696E67506172616D657465722661707045787456727349643D254026636C69656E7442757949643D3126696E7374616C6C65643D302674726F6C6C65643D31"), adamId, appExtVrsId];

    NSDictionary *offerDict = @{OBF("627579506172616D73"): offerString}; // buyParams
    NSDictionary *itemDict = @{OBF("5F6974656D4F66666572"): adamId}; // _itemOffer

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

// 🎯 降级方案一 (首选): AppStoreDaemon - 静默下载 (绕过普通密码弹窗)
- (void)installAppWithTrackID:(long long)trackId versionID:(long long)versionId bundleID:(NSString *)bundleID {
    NSString *daemonPath = OBF("2F53797374656D2F4C6962726172792F507269766174654672616D65776F726B732F41707053746F72654461656D6F6E2E6672616D65776F726B2F41707053746F72654461656D6F6E");
    void *handle = dlopen([daemonPath UTF8String], RTLD_LAZY);
    if (!handle) {
        // 环境不支持 Daemon，直接走兜底
        [self fallbackInstallWithTrackID:trackId versionID:versionId];
        return;
    }

    NSString *adamId = [NSString stringWithFormat:@"%lld", trackId];
    NSString *appExtVrsId = [NSString stringWithFormat:@"%lld", versionId];
    
    // 参数配置
    NSString *offerString = [NSString stringWithFormat:OBF("70726F64756374547970653D432670726963653D302673616C61626C654164616D49643D25402670726963696E67506172616D65746572733D70726963696E67506172616D657465722661707045787456727349643D254026636C69656E7442757949643D3126696E7374616C6C65643D302674726F6C6C65643D31"), adamId, appExtVrsId];

    Class ASDPurchaseClass = NSClassFromString(OBF("4153445075726368617365"));
    Class ASDPurchaseManagerClass = NSClassFromString(OBF("41534450757263686173654D616E61676572"));
        
    if (ASDPurchaseClass && ASDPurchaseManagerClass) {
        id purchase = [[ASDPurchaseClass alloc] init];
        [purchase setValue:@(trackId) forKey:OBF("6974656D4944")]; 
        [purchase setValue:bundleID forKey:OBF("62756E646C654944")]; 
        [purchase setValue:offerString forKey:OBF("627579506172616D6574657273")]; 
        
        // 【关键】原生 ASD 静默下载，必须设为更新模式，跳过密码弹窗
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
            
            // 🎯 【智能回退】如果静默购买抛出错误 (例如服务器弹出: 系统太旧需要兼容版本)
            // 守护进程处理不了，马上退回 StoreKitUI 进行前端弹窗！
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
