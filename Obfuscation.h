// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#import <Foundation/Foundation.h>

// 1. 类名极致视觉致盲
#define ARAppDelegate           O0O00O0O
#define ARDowngradeManager      O00OO00O
#define ARRootViewController    OO000OO0
#define ARVersionViewController O0O0O00O

// 2. 自定义属性与方法极致致盲
#define arAllApps               I1l1I1ll
#define arFilteredApps          ll1I1l1I
#define arSearchController      l1I1I1ll
#define loadInstalledApps       Ill111lI
#define arOpenTGChannel         lI1l111l
#define sharedManager           l111lI1I

// 3. 终极内存解密：Hex 转 String (替代所有明文，逆向工具彻底瞎眼)
static inline NSString * l1I1l_dec(const char *hex) {
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

// 宏包装器
#define OBF(hex) l1I1l_dec(hex)

#endif /* Obfuscation_h */
