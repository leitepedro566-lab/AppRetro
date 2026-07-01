// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

// 🎯 新增环境检测宏：如果是编译 Objective-C 文件才加载，编译汇编文件则跳过
#ifdef __OBJC__ 

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <unistd.h>

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

// 3. Custom Methods - 彻底抹除所有自定义方法的特征签名
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
#define fetchVersionData               _v1D9f4X_
#define inputCustomVersion             _i2C8v5M_
#define applyRoundedUIToAlert          _a3R7u6T_
#define handleOwnershipMismatchWithPurchaser _h4O1m9W_

// 4. 🎯 顶尖动态防护：反调试、反注入、反动态分析 (构造函数，在 main 之前多重触发执行)
__attribute__((constructor)) static void _AR_SecInit_0x(void) {
    // 检测 1: PT_DENY_ATTACH (阻断常规调试器附加)
    void *handle = dlopen("/usr/lib/system/libsystem_kernel.dylib", RTLD_LAZY);
    if (handle) {
        typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
        ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(handle, "ptrace");
        if (ptrace_ptr) { ptrace_ptr(31, 0, 0, 0); } 
    }
    
    // 检测 2: sysctl P_TRACED 标志位 (应对绕过 ptrace 的高阶调试)
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    struct kinfo_proc info;
    size_t size = sizeof(info);
    sysctl(mib, 4, &info, &size, NULL, 0);
    if (info.kp_proc.p_flag & P_TRACED) {
        // 内联汇编强制进行 Syscall 退出，绕过符号断点
        __asm__ __volatile__("mov x0, #0\nmov x16, #1\nsvc #0x80"); 
    }
}

// 5. 顶级内联安全脱壳机 + 干扰 IDA/Hopper 静态分析的花指令与虚假控制流
static __attribute__((always_inline, nodebug)) inline NSString * _l1ll1l1O_(const char *hex) {
    int len = (int)strlen(hex);
    
    // 虚假控制流与寄存器状态污染
    volatile int junk1 = 0xDEADBEEF;
    volatile int junk2 = 0xCAFEBABE;
    junk1 ^= junk2;
    
    char *str = (char *)malloc(len / 2 + 1);
    for(int i = 0; i < len; i += 2) {
        __asm__ __volatile__("nop"); // 汇编级花指令，破坏反编译器对循环的推断
        char byte[3] = {hex[i], hex[i+1], 0};
        str[i/2] = (char)(strtol(byte, NULL, 16) ^ 0);
        junk1 += i; 
    }
    str[len/2] = '\0';
    NSString *res = [NSString stringWithUTF8String:str];
    free(str);
    
    if (junk1 == 0x12345678) {
        __asm__ __volatile__("udf #0"); // 迷惑性分支，故意抛出非法指令，永远不会执行到这
    }
    
    return res;
}

#define OBF(x) _l1ll1l1O_(x)

#endif /* __OBJC__ */ // 🎯 结束环境检测宏

#endif /* Obfuscation_h */
