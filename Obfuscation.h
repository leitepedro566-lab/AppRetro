// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#ifdef __OBJC__

#import <Foundation/Foundation.h>

// 🎯 全局 Metadata 深度毒化：埋设破坏 class-dump 和 IDA 解析引擎的地雷
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

// =====================================================================
// 🎯 全覆盖极限乱码 (40位条形码)
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
// 🎯 降维打击 1: 纯汇编级内核调用 (彻底消灭外部导入符号 dlopen/dlsym/sysctl/ptrace)
// =====================================================================
__attribute__((constructor)) static void _AR_SecInit_0x(void) {
    // Syscall 26: ptrace(PT_DENY_ATTACH, 0, 0, 0)
    // 从导入表中抹除 ptrace，IDA 无法顺藤摸瓜
    __asm__ volatile(
        "mov x0, #31\n"
        "mov x1, #0\n"
        "mov x2, #0\n"
        "mov x3, #0\n"
        "mov x16, #26\n"
        "svc #0x80\n"
    );

    // Syscall 202: sysctl (P_TRACED 检测)
    // 消灭 sysctl 符号。采用内联汇编直接发内核中断
    int mib[4] = {1, 14, 1, getpid()}; // CTL_KERN, KERN_PROC, KERN_PROC_PID
    struct {
        uint32_t p_reserved1[10];
        int p_flag;
        uint32_t p_reserved2[96];
    } info;
    size_t size = sizeof(info);
    
    int ret;
    __asm__ volatile(
        "mov x0, %[mib]\n"
        "mov x1, #4\n"
        "mov x2, %[info]\n"
        "mov x3, %[size]\n"
        "mov x4, #0\n"
        "mov x5, #0\n"
        "mov x16, #202\n"
        "svc #0x80\n"
        "mov %[ret], x0\n"
        : [ret] "=r" (ret)
        : [mib] "r" (mib), [info] "r" (&info), [size] "r" (&size)
        : "x0", "x1", "x2", "x3", "x4", "x5", "x16", "memory"
    );

    if (info.p_flag & 0x00000800) { // P_TRACED
        // 发现被附加，汇编级别强杀进程
        __asm__ volatile("mov x0, #0\nmov x16, #1\nsvc #0x80"); 
    }
}

// =====================================================================
// 🎯 降维打击 2 & 3: IDA F5 粉碎机 + 零依赖字符串解密
// 完全废弃 malloc, strlen, strtol，让 IDA 找不到任何库函数的交叉引用
// =====================================================================
static __attribute__((always_inline, nodebug)) inline NSString * _l1ll1l1O_(const char *hex) {
    // 1. 手写 strlen，消灭对 libc 符号的依赖
    int len = 0;
    while(hex[len] != '\0') { len++; }
    
    // 2. 利用栈内存动态分配 (VLA)，彻底消灭对 malloc/free 的依赖
    char str[len / 2 + 1];
    volatile int junk = 0xBADF00D;
    
    for(int i = 0; i < len; i += 2) {
        // 3. 🎯 注入 IDA 伪代码粉碎机 (SP-Analysis Sabotage)
        // 强制破坏栈帧平衡的静态分析，导致按 F5 反编译时直接报错 "SP analysis failed"
        __asm__ volatile (
            "b 1f\n"
            ".long 0xDEADBEEF\n" // 插入垃圾字节迷惑反汇编引擎
            "1:\n"
            "add sp, sp, #0x10\n"
            "sub sp, sp, #0x10\n" // 运行时平栈，但会搞死静态分析
        );

        // 4. 手写 16进制转字符，消灭 strtol
        char c1 = hex[i];
        char c2 = hex[i+1];
        char v1 = (c1 >= '0' && c1 <= '9') ? (c1 - '0') : ((c1 & ~0x20) - 'A' + 10);
        char v2 = (c2 >= '0' && c2 <= '9') ? (c2 - '0') : ((c2 & ~0x20) - 'A' + 10);
        str[i/2] = (v1 << 4) | v2;
        
        junk ^= (v1 + v2);
    }
    str[len/2] = '\0';
    
    // 极度复杂的虚假分支，防止 CFG 树被轻易重构
    if ((junk * junk) % 2 != 0) {
        __asm__ volatile ("udf #0"); 
    }
    
    // 全文唯一的外部依赖只剩下 Foundation 框架自身，完美隐匿
    return [NSString stringWithUTF8String:str];
}

#define OBF(x) _l1ll1l1O_(x)

#endif /* __OBJC__ */
#endif /* Obfuscation_h */
