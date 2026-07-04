// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#ifdef __OBJC__ 

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <unistd.h>

// 🎯 毒化节区注入：故意向 ObjC Metadata 注入破坏性控制字符，直接令 class-dump 和 Hopper 解析崩溃或乱码
__asm__(
    ".section __TEXT,__objc_classname,cstring_literals\n"
    ".asciz \"\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0B\\x0C\\x0E\\x0F\"\n"
    ".asciz \"<Invalid_Class_Dump_Crash>\"\n"
);

// 1. Classes - 顶级“条形码”类名混淆 (乱码化)
#define ARAppDelegate                  _l1Il0O1lI_
#define ARDowngradeManager             _O01lIl1O0_
#define ARRootViewController           _lI1O0l1Il_
#define ARVersionViewController        _1lI0OlI1l_

// 2. Properties & Ivars - 属性乱码化
#define bundleID                       _ll11II00OO_
#define appName                        _OO00II11ll_
#define trackID                        _lI0O1lI0O1_
#define versions                       _1O0Il1O0Il_
#define arAllApps                      _l1I1O0O0lI_
#define arFilteredApps                 _O0lIl1I1O0_
#define arSearchController             _lI1O0O0l1I_
#define appPhysicalPath                _1lI1O0lI0O_

// 3. Custom Methods - 方法名乱码化
#define fetchTrackIDForBundleID        _O01lI0lI1O_
#define fetchVersionsForTrackID        _l1IO0l1O0I_
#define verifyOwnershipForBundleID     _1lI0O1lI0O_
#define executeAccountSwitchToName     _O0l1I1lI0O_
#define installAppWithTrackID          _lI0O0l1I1l_
#define fallbackInstallWithTrackID     _1O0I1lO0Il_
#define executeDowngradeProcessWithVersionStr _l1I1lO0O0I_
#define loadInstalledApps              _O0l1O0Il1I_
#define arOpenTGChannel                _lI1O0l1O0I_
#define sharedManager                  _1lI0Ol1O0I_
#define recursiveFetchTrackID          _O01lI0l1O0_
#define fetchVersionData               _ll0011IIOO_
#define inputCustomVersion             _OO1100llII_
#define applyRoundedUIToAlert          _1lI0O0l1I1_
#define handleOwnershipMismatchWithPurchaser _O0l1I1O0Il_

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
        __asm__ __volatile__("nop");
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
