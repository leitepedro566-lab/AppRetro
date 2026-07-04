// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#ifdef __OBJC__

#import <Foundation/Foundation.h>

// 🎯 全局 Metadata 深度毒化：埋设引发静态分析工具缓冲区溢出的地雷
__asm__(
    ".section __TEXT,__objc_classname,cstring_literals\n"
    ".asciz \"\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0B\\x0C\\x0E\\x0F\"\n"
    ".asciz \"+[-[\\\\^$*+?.()|{}[]\"\n"
    ".section __TEXT,__objc_methname,cstring_literals\n"
    ".asciz \"\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0B\\x0C\\x0E\\x0F\"\n"
    ".asciz \"!@#%&*;:'\\\"<>,./?~`\"\n"
    ".fill 500, 1, 0x21\n" // 植入 500 个感叹号引发旧版 class-dump 读取越界崩溃
    ".byte 0\n"
    ".section __TEXT,__objc_methtype,cstring_literals\n"
    ".asciz \"\\x01\\x02\\x03\\x04\\x05\\x06\\x07\\x08\\x09\\x0B\\x0C\\x0E\\x0F\"\n"
    ".asciz \"v@:!\"\n"
);

// =====================================================================
// 🎯 全覆盖极限乱码 (40位盲区条形码)
// =====================================================================
#define AR_AppDelegate                        _O0l1I1lO0l1I1lO0l1I1lO0l1I1lO0l1I1lO0l1I_
#define AR_DowngradeManager                   _1lI1O0O1lI1O0O1lI1O0O1lI1O0O1lI1O0O1lI1O_
#define AR_RootViewController                 _l1I1l0O0l1I1l0O0l1I1l0O0l1I1l0O0l1I1l0O0_
#define AR_VersionViewController              _O0O0l1I1l1O0O0l1I1l1O0O0l1I1l1O0O0l1I1l1_
#define AR_bundleID                           _1l11l1l1lO0O0O0O1l11l1l1lO0O0O0O1l11l1l_
#define AR_appName                            _O0OO0O0Ol1I1l1l1I1lO0OO0O0Ol1I1l1l1I1l_
#define AR_trackID                            _0O00O0O0l1I1O0O0l0l0O00O0O0l1I1O0O0l0l_
#define AR_versions                           _l1Il1I1lO0O0l1I1l1ll1Il1I1lO0O0l1I1l1l_
#define AR_arAllApps                          _1Il0O0lI1Il0O0lI1Il0O0lI1Il0O0lI1Il0O0_
#define AR_arFilteredApps                     _O0l1O0Il1IO0l1O0Il1IO0l1O0Il1IO0l1O0Il_
#define AR_arSearchController                 _lI1O0O0l1IlI1O0O0l1IlI1O0O0l1IlI1O0O0l_
#define AR_appPhysicalPath                    _1O0I1lO0Il1O0I1lO0Il1O0I1lO0Il1O0I1lO0_
#define AR_sharedManager                      _O0O0O0O0O0l1l1l1l1lO0O0O0O0O0l1l1l1l1l_
#define AR_fetchTrackIDForBundleID            _l1l1l1l1l1O0O0O0O0Ol1l1l1l1l1O0O0O0O0O_
#define AR_completion                         _1lI1lI1lI1O0O0O0O0O1lI1lI1lI1O0O0O0O0O_
#define AR_fetchVersionsForTrackID            _O0O0O0O0O01lI1lI1lIO0O0O0O0O01lI1lI1lI_
#define AR_installAppWithTrackID              _l1I1O0O0l1l1I1O0O0l1l1I1O0O0l1l1I1O0O0_
#define AR_versionID                          _O0l1I1l0O0O0l1I1l0O0O0l1I1l0O0O0l1I1l0_
#define AR_verifyOwnershipForBundleID         _1l1I0O0l1I1l1I0O0l1I1l1I0O0l1I1l1I0O0l_
#define AR_appPath                            _O0O1l1I0O0O0O1l1I0O0O0O1l1I0O0O0O1l1I0_
#define AR_executeAccountSwitchToName         _l1I0O0l1I1l1I0O0l1I1l1I0O0l1I1l1I0O0l1_
#define AR_backupAllAppStoreVersionsWithCompletion _1lI1O0O01lI1O0O01lI1O0O01lI1O0O01lI1O0_
#define AR_recursiveFetchTrackID              _O0O0l1I1l1I1O0O0O0O0l1I1l1I1O0O0O0O0l1_
#define AR_codes                              _l1I1l1I1l1O0O0l1I1l1l1I1l1I1l1O0O0l1I1_
#define AR_index                              _1l11l1l1l1O0O0O0O0O01l11l1l1l1O0O0O0O0_
#define AR_fallbackInstallWithTrackID         _O0OO0O0O0O0l1I1l1I1lO0OO0O0O0O0l1I1l1I_
#define AR_setupRightMenuButton               _l1Il1I1l1I1lO0O0O0O0l1Il1I1l1I1lO0O0O0_
#define AR_showBackupConfirmation             _1lI1lI1lO0O0O0O0l1I11lI1lI1lO0O0O0O0l1_
#define AR_startBackupProcess                 _O0l1I1lO0l1I1lO0l1I1O0l1I1lO0l1I1lO0l1_
#define AR_arOpenTGChannel                    _l1I1O0O0l1I1O0O0l1I1l1I1O0O0l1I1O0O0l1_
#define AR_loadInstalledApps                  _1O0O0O0O0O0l1l1l1l1l1O0O0O0O0O0l1l1l1l_
#define AR_inputCustomVersion                 _O0O0O0O0O01l11l1l1l1O0O0O0O0O01l11l1l1_
#define AR_fetchVersionData                   _l1l1l1l1l1O0O0O0O0O0l1l1l1l1l1O0O0O0O0_
#define AR_applyRoundedUIToAlert              _1lI1lI1l1lI1lI1lO0O01lI1lI1l1lI1lI1lO0_
#define AR_handleOwnershipMismatchWithPurchaser _O0O0O0O01lI1lI1lO0O0O0O0O0O01lI1lI1lO0_
#define AR_active                             _l1I1O0O0l1I1O0O0O0O0l1I1O0O0l1I1O0O0O0_
#define AR_allAccounts                        _1lI1O0O0O0l1I1l1I1l11lI1O0O0O0l1I1l1I1_
#define AR_versionStr                         _O0l1I1l0O0O0l1I1lO0OO0l1I1l0O0O0l1I1lO_
#define AR_indexPath                          _l1I0O0l1I1l1I0O0O0O0l1I0O0l1I1l1I0O0O0_
#define AR_executeDowngradeProcessWithVersionStr _1l1I0O0l1I1l1I0O0O0O1l1I0O0l1I1l1I0O0O_

// =====================================================================
// 🎯 降维打击 1: 纯汇编脱核驱动 (零 libc 导入，消灭 sysctl/getpid/ptrace 符号)
// =====================================================================
__attribute__((constructor)) static void _AR_SecInit_0x(void) {
    // 1. Syscall 26: ptrace(PT_DENY_ATTACH)
    register long p0 __asm__("x0") = 31;
    register long p1 __asm__("x1") = 0;
    register long p2 __asm__("x2") = 0;
    register long p3 __asm__("x3") = 0;
    register long p16 __asm__("x16") = 26;
    __asm__ volatile("svc #0x80" : "+r"(p0) : "r"(p1), "r"(p2), "r"(p3), "r"(p16) : "memory");

    // 2. Syscall 20: getpid() -> 完全摆脱 libc 的 getpid()
    register long pid_x0 __asm__("x0");
    register long pid_x16 __asm__("x16") = 20;
    __asm__ volatile("svc #0x80" : "=r"(pid_x0) : "r"(pid_x16) : "memory");

    // 3. Syscall 202: sysctl (P_TRACED 检测)
    int mib[4] = {1, 14, 1, (int)pid_x0}; 
    struct {
        uint32_t p_reserved1[10];
        int p_flag;
        uint32_t p_reserved2[96];
    } info;
    size_t size = sizeof(info);
    
    register long s0 __asm__("x0") = (long)mib;
    register long s1 __asm__("x1") = 4;
    register long s2 __asm__("x2") = (long)&info;
    register long s3 __asm__("x3") = (long)&size;
    register long s4 __asm__("x4") = 0;
    register long s5 __asm__("x5") = 0;
    register long s16 __asm__("x16") = 202;
    __asm__ volatile("svc #0x80" : "+r"(s0) : "r"(s1), "r"(s2), "r"(s3), "r"(s4), "r"(s5), "r"(s16) : "memory");

    if (info.p_flag & 0x00000800) { // P_TRACED
        __asm__ volatile("mov x0, #0\nmov x16, #1\nsvc #0x80"); // Syscall 1: exit(0)
    }
}

// =====================================================================
// 🎯 降维打击 2 & 3: 零 libc 内存管理 + IDA F5 图形粉碎机 + 极速内存销毁
// =====================================================================
static __attribute__((always_inline, nodebug)) inline NSString * _l1ll1l1O_(const char *hex) {
    // 纯手动内联 strlen，无任何函数调用
    size_t len = 0;
    while(hex[len] != '\0') { len++; }
    size_t byteLen = len / 2;

    // Syscall 197: mmap (绕过 libc 的 malloc，动态申请匿名内存页，IDA 彻底瞎掉)
    register long m0 __asm__("x0") = 0;
    register long m1 __asm__("x1") = byteLen + 1;
    register long m2 __asm__("x2") = 3;       // PROT_READ|PROT_WRITE
    register long m3 __asm__("x3") = 0x1002;  // MAP_ANON|MAP_PRIVATE
    register long m4 __asm__("x4") = -1;
    register long m5 __asm__("x5") = 0;
    register long m16 __asm__("x16") = 197;
    __asm__ volatile("svc #0x80" : "+r"(m0) : "r"(m1), "r"(m2), "r"(m3), "r"(m4), "r"(m5), "r"(m16) : "memory");
    
    char *str = (char *)m0;
    volatile int junk = 0;
    
    for(size_t i = 0; i < len; i += 2) {
        // 🎯 IDA CFG (控制流图) 终极粉碎机
        // 使用间接分支 br 跨过 8 字节的无效/脏机器码，强制打断反编译器的基本块连接
        __asm__ volatile (
            "adr x16, 1f\n"
            "br x16\n"
            ".long 0xDEADBEEF\n" // 脏数据 1，破坏指令对齐
            ".long 0xCAFEBABE\n" // 脏数据 2
            "1:\n"
        );

        // 纯手动 16进制转字符，绕过 strtol
        char c1 = hex[i], c2 = hex[i+1];
        char v1 = (c1 >= '0' && c1 <= '9') ? (c1 - '0') : ((c1 & ~0x20) - 'A' + 10);
        char v2 = (c2 >= '0' && c2 <= '9') ? (c2 - '0') : ((c2 & ~0x20) - 'A' + 10);
        str[i/2] = (v1 << 4) | v2;
        junk ^= str[i/2];
    }
    str[byteLen] = '\0';
    
    // 不可达代码：防汇编引擎优化
    if ((junk % 2) != (junk % 2)) {
        __asm__ volatile ("udf #0"); 
    }
    
    NSString *res = [NSString stringWithUTF8String:str];

    // 🎯 毫秒级内存反刮削 (Zeroization)
    for(size_t i = 0; i < byteLen; i++) {
        ((volatile char *)str)[i] = 0;
    }

    // Syscall 73: munmap (绕过 libc 的 free，直接让内核收回内存页)
    register long u0 __asm__("x0") = (long)str;
    register long u1 __asm__("x1") = byteLen + 1;
    register long u16 __asm__("x16") = 73;
    __asm__ volatile("svc #0x80" : "+r"(u0) : "r"(u1), "r"(u16) : "memory");

    return res;
}

#define OBF(x) _l1ll1l1O_(x)

#endif /* __OBJC__ */
#endif /* Obfuscation_h */
