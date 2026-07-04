// Obfuscation.h
#ifndef Obfuscation_h
#define Obfuscation_h

#ifdef __OBJC__

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <unistd.h>

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
// 🎯 全覆盖极限乱码：将所有带 AR_ 前缀的自定义符号映射为 40位条形码
// =====================================================================

// Classes
#define AR_AppDelegate                        _O0l1I1lO0l1I1lO0l1I1lO0l1I1lO0l1I1lO0l1I_
#define AR_DowngradeManager                   _1lI1O0O1lI1O0O1lI1O0O1lI1O0O1lI1O0O1lI1O_
#define AR_RootViewController                 _l1I1l0O0l1I1l0O0l1I1l0O0l1I1l0O0l1I1l0O0_
#define AR_VersionViewController              _O0O0l1I1l1O0O0l1I1l1O0O0l1I1l1O0O0l1I1l1_

// Properties
#define AR_bundleID                           _1l11l1l1lO0O0O0O1l11l1l1lO0O0O0O1l11l1l_
#define AR_appName                            _O0OO0O0Ol1I1l1l1I1lO0OO0O0Ol1I1l1l1I1l_
#define AR_trackID                            _0O00O0O0l1I1O0O0l0l0O00O0O0l1I1O0O0l0l_
#define AR_versions                           _l1Il1I1lO0O0l1I1l1ll1Il1I1lO0O0l1I1l1l_
#define AR_arAllApps                          _1Il0O0lI1Il0O0lI1Il0O0lI1Il0O0lI1Il0O0_
#define AR_arFilteredApps                     _O0l1O0Il1IO0l1O0Il1IO0l1O0Il1IO0l1O0Il_
#define AR_arSearchController                 _lI1O0O0l1IlI1O0O0l1IlI1O0O0l1IlI1O0O0l_
#define AR_appPhysicalPath                    _1O0I1lO0Il1O0I1lO0Il1O0I1lO0Il1O0I1lO0_

// Methods & Params (方法名与参数名拆解全混淆)
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
// 🎯 顶尖动态防护与字符串混淆
// =====================================================================

__attribute__((constructor)) static void _AR_SecInit_0x(void) {
    void *handle = dlopen("/usr/lib/system/libsystem_kernel.dylib", RTLD_LAZY);
    if (handle) {
        typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
        ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(handle, "ptrace");
        if (ptrace_ptr) { ptrace_ptr(31, 0, 0, 0); } 
    }
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    struct kinfo_proc info;
    size_t size = sizeof(info);
    sysctl(mib, 4, &info, &size, NULL, 0);
    if (info.kp_proc.p_flag & P_TRACED) {
        __asm__ __volatile__("mov x0, #0\nmov x16, #1\nsvc #0x80"); 
    }
}

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
