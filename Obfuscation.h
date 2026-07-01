// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#import <Foundation/Foundation.h>

// 1. 类名极致视觉模糊 (随机 0, O, I, l 组合)
#define ARAppDelegate           O0O00O0O
#define ARDowngradeManager      O00OO00O
#define ARRootViewController    OO000OO0
#define ARVersionViewController O0O0O00O

// 2. 核心内部公开/私有属性变态致盲
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
#define appPhysicalPath         m_0O001l

// 3. 顶级内联安全脱壳机 + 干扰静态分析的花指令
static __attribute__((always_inline)) inline NSString * _l1ll1l1O_(const char *hex) {
    int len = (int)strlen(hex);
    
    // 花指令：干扰 IDA 的寄存器分析，无实际意义
    volatile int junk = 0;
    junk += len;
    junk ^= 0xDEADBEEF;
    
    char *str = (char *)malloc(len / 2 + 1);
    for(int i = 0; i < len; i += 2) {
        char byte[3] = {hex[i], hex[i+1], 0};
        str[i/2] = (char)strtol(byte, NULL, 16);
        junk -= i; // 继续花指令干扰
    }
    str[len/2] = '\0';
    NSString *res = [NSString stringWithUTF8String:str];
    free(str);
    
    if (junk == 0x12345678) { res = nil; } // 迷惑分支，永远不会执行
    
    return res;
}

#define OBF(x) _l1ll1l1O_(x)

#endif /* Obfuscation_h */
