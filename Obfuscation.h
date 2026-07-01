// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#import <Foundation/Foundation.h>

// 1. Classes - 彻底打乱类名，从 Mach-O 符号表中抹除所有明文类名特征
#define ARAppDelegate                  _X8jL2mQ9pA_
#define ARDowngradeManager             _P3kR7xN1cL_
#define ARRootViewController           _V9aB4wY2zM_
#define ARVersionViewController        _M6tH1kF8dJ_

// 2. Properties & Ivars - 把所有属性变量变成绝对乱码符号
#define bundleID                       _z9Q1wL3_
#define appName                        _y4R8vB7_
#define trackID                        _x2J5kN9_
#define versions                       _w7P4mC2_
#define arAllApps                      _v1H6tX5_
#define arFilteredApps                 _u5D9gF1_
#define arSearchController             _t8M2bS4_
#define appPhysicalPath                _s3K7zV6_

// 3. Custom Methods - 彻底抹除所有自定义方法的特征签名（连协议方法也无影无踪）
#define fetchTrackIDForBundleID        _a7B2c8D_
#define fetchVersionsForTrackID        _e4F9g1H_
#define verifyOwnershipForBundleID     _i6J3k5L_
#define executeAccountSwitchToName     _m8N2p4Q_
#define installAppWithTrackID          _r1S7t9V_
#define fallbackInstallWithTrackID     _w5X2y6Z_
#define executeDowngradeProcessWithVersionStr _b3C8d1F_
#define loadInstalledApps              _g5H2j9K_
#define arOpenTGChannel                _l4M7n2P_
#define sharedManager                  _q6R1s8T_
#define recursiveFetchTrackID          _v3W9x4Y_

// 4. 顶级内联安全脱壳机 + 干扰静态分析的花指令
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
