// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#import <Foundation/Foundation.h>

// 1. 类名极致视觉致盲
#define ARAppDelegate           O0O00O0O
#define ARDowngradeManager      O00OO00O
#define ARRootViewController    OO000OO0
#define ARVersionViewController O0O0O00O

// 2. 核心属性与方法名致盲 (从符号表中彻底抹除特征)
#define bundleID                m_O0O0l1
#define appName                 m_l1l1O0
#define trackID                 m_1l1lO0
#define versions                m_0O0Ol1
#define arAllApps               m_I1l1I1
#define arFilteredApps          m_ll1I1l
#define arSearchController      m_l1I1I1
#define loadInstalledApps       m_Ill111
#define arOpenTGChannel         m_lI1l11
#define fetchTrackIDForBundleID m_lIl1I0
#define fetchVersionsForTrackID m_l11I1l
#define installAppWithTrackID   m_l1l11l
#define sharedManager           m_l111lI

// 3. 终极内联解密器：强制内联消灭函数符号，彻底阻断交叉引用分析
static __attribute__((always_inline)) inline NSString * _O0l1O0l1_(const char *hex) {
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

#define OBF(x) _O0l1O0l1_(x)

#endif /* Obfuscation_h */
