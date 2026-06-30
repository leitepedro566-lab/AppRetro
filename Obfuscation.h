// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#import <Foundation/Foundation.h>

// 1. 视觉致盲：类名混淆
#define ARAppDelegate           lIII1l1lI
#define ARDowngradeManager      l1I1ll1lI
#define ARRootViewController    II11ll11I
#define ARVersionViewController I1I11l1lI

// 2. 视觉致盲：避免冲突的私有属性与方法混淆
#define arAllApps               o_1I11l
#define arFilteredApps          o_l1I1I
#define arSearchController      o_11llI
#define fetchTrackIDForBundleID o_lIl1I
#define fetchVersionsForTrackID o_11I1l
#define installAppWithTrackID   o_1l11l
#define sharedManager           o_II11l

// 3. 终极内存解密：Hex 转 String (替代所有明文字符串，干掉静态特征)
static inline NSString * HEX_DEC(const char *hex) {
    int len = (int)strlen(hex);
    char *str = (char *)malloc(len / 2 + 1);
    for(int i = 0; i < len; i += 2) {
        char byte[3] = {hex[i], hex[i+1], 0};
        str[i/2] = (char)strtol(byte, NULL, 16);
    }
    str[len/2] = '\0';
    NSString *res = [NSString stringWithUTF8String:str];
    free(str);
    return res;
}

#endif /* Obfuscation_h */
