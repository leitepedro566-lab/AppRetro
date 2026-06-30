// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#import <Foundation/Foundation.h>

// 1. 类名极致致盲
#define ARAppDelegate           l111lIlIl
#define ARDowngradeManager      lIllIIl1l
#define ARRootViewController    ll1I1lIll
#define ARVersionViewController lIIl1ll1l

// 2. 自定义关键属性与方法混淆（避开系统原有关键字）
#define arAllApps               m_l1I11l
#define arFilteredApps          m_l1l1I1
#define arSearchController      m_l11llI
#define fetchTrackIDForBundleID m_lIl1I
#define fetchVersionsForTrackID m_l11I1l
#define installAppWithTrackID   m_l1l11l
#define sharedManager           m_lII11l
#define arOpenTGChannel         m_l1ll1l
#define loadInstalledApps       m_l111lI

// 3. 终极内存解密：Hex 转 String (使静态分析中无任何明文字符串)
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
