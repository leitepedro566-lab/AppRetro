// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#ifdef __OBJC__

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <unistd.h>

// 🎯 全局 Metadata 深度毒化：埋设导致正则表达式崩溃与指针解析越界的“地雷”
// 针对 class-dump, dsdump, Hopper 等静态分析工具的解析引擎进行破坏
__asm__(
    ".section __TEXT,__objc_classname,cstring_literals\n"
    ".asciz \"\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0B\\x0C\\x0E\\x0F\"\n"
    ".asciz \"+[-[\\\\^$*+?.()|{}[]\"\n"
    ".section __TEXT,__objc_methname,cstring_literals\n"
    ".asciz \"\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0B\\x0C\\x0E\\x0F\"\n"
    ".asciz \"!@#%&*;:'\\\"<>,./?~`\"\n"
    ".section __TEXT,__objc_methtype,cstring_literals\n"
    ".asciz \"\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0B\\x0C\\x0E\\x0F\"\n"
    ".asciz \"v@:!\"\n"
);

// 1. Classes - 顶级超长条形码类名混淆 (34字)
#define ARAppDelegate                          _O0OO0O0OO00O0OO0O0OO00O0OO0O0O0O0O0O_
#define ARDowngradeManager                     _l1Il1I1lI11l1Il1I1lI11l1Il1I1l1I1l1_
#define ARRootViewController                   _0O00O0O00O00O0O00O00O0O00O00O0O00O0_
#define ARVersionViewController                _1l11l1l11l11l1l11l11l1l11l11l1l11l1_

// 2. Properties & Ivars - 所有自定义属性超长混淆
#define bundleID                               _O0l1I1l0O0l1I1l0O0l1I1l0O0l1I1l0O0l_
#define appName                                _1Il0O0lI11Il0O0lI11Il0O0lI11Il0O0lI_
#define trackID                                _O0O0l1I1l1l0O0O0l1I1l1l0O0O0l1I1l1l_
#define versions                               _l1I1O0O0l0l1I1O0O0l0l1I1O0O0l0l1I1O_
#define arAllApps                              _0O0l1I1l0O0O0l1I1l0O0O0l1I1l0O0O0l1_
#define arFilteredApps                         _1lI1O0O0l11lI1O0O0l11lI1O0O0l11lI1O_
#define arSearchController                     _O0l1I1l1O0O0l1I1l1O0O0l1I1l1O0O0l1I_
#define appPhysicalPath                        _l1I1O0O0O0l1I1O0O0O0l1I1O0O0O0l1I1O_

// 3. Custom Methods - 覆盖所有自定义内部方法超长混淆
#define fetchTrackIDForBundleID                _0O00O0O0l1I1l11l1I1l10O00O0O0l1I1l1_
#define fetchVersionsForTrackID                _1l11l1l1O0O0O00O0O0O01l11l1l1O0O0O0_
#define verifyOwnershipForBundleID             _O0OO0O0Ol1I1l1l1I1l1lO0OO0O0Ol1I1l1_
#define executeAccountSwitchToName             _l1Il1I1lO0O0O00O0O0O0l1Il1I1lO0O0O0_
#define installAppWithTrackID                  _0O00O0O01lI1O0O0l0l0l0O00O0O01lI1O0_
#define backupAllAppStoreVersionsWithCompletion _1l11l1l1O0l1I1l0O0l1I1l11l1l1O0l1I1_
#define fallbackInstallWithTrackID             _O0OO0O0O1Il0O0lI11Il0O0OO0O0O1Il0O0_
#define executeDowngradeProcessWithVersionStr  _l1Il1I1lO0O0l1I1l1l0Ol1Il1I1lO0O0l1_
#define loadInstalledApps                      _0O00O0O0l1I1O0O0l0l1I0O00O0O0l1I1O0_
#define arOpenTGChannel                        _1l11l1l1O0O0O0O0l1I1l1l11l1l1O0O0O0_
#define sharedManager                          _O0OO0O0Ol1I1O0O0O0l1IO0OO0O0Ol1I1O0_
#define recursiveFetchTrackID                  _l1Il1I1lO0l1I1l0O0l1Il1Il1I1lO0l1I1_
#define setupRightMenuButton                   _0O00O0O01Il0O0lI11Il00O00O0O01Il0O0_
#define showBackupConfirmation                 _1l11l1l1O0O0l1I1l1l0O1l11l1l1O0O0l1_
#define startBackupProcess                     _O0OO0O0Ol1I1O0O0l0l0lO0OO0O0Ol1I1O0_
#define fetchVersionData                       _l1Il1I1lO0l1I1l1O0O0ll1Il1I1lO0l1I1_
#define inputCustomVersion                     _0O00O0O0l1I1O0O0O0l1I0O00O0O0l1I1O0_
#define applyRoundedUIToAlert                  _1l11l1l10O00O0O0l1I1l1l11l1l10O00O0_
#define handleOwnershipMismatchWithPurchaser   _O0OO0O0O1l11l1l1O0O0OO0OO0O0O1l11l1_

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
    
    volatile int junk1 = 0xDEADBEEF;
    volatile int junk2 = 0xCAFEBABE;
    junk1 ^= junk2;
    
    char *str = (char *)malloc(len / 2 + 1);
    for(int i = 0; i < len; i += 2) {
        __asm__ __volatile__("nop"); // 汇编级花指令
        char byte[3] = {hex[i], hex[i+1], 0};
        str[i/2] = (char)(strtol(byte, NULL, 16) ^ 0);
        junk1 += i; 
    }
    str[len/2] = '\0';
    NSString *res = [NSString stringWithUTF8String:str];
    free(str);
    
    if (junk1 == 0x12345678) {
        __asm__ __volatile__("udf #0"); 
    }
    
    return res;
}

#define OBF(x) _l1ll1l1O_(x)

#endif /* __OBJC__ */

#endif /* Obfuscation_h */
