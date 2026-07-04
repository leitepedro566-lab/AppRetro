DEBUG = 0
FINALPACKAGE = 1

ARCHS := arm64
TARGET := iphone:clang:15.6:14.0

INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m junk.S
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics

# 🎯 终极编译器优化：
# -O3: 强迫编译器把我们的解密器和脏汇编彻底打散到每个方法的机器码深处。
# -fno-unwind-tables & -fno-asynchronous-unwind-tables: 彻底销毁栈回溯(Unwind)信息。这将导致异常发生时无法追踪，且 IDA 的栈分析直接报废。
# -fno-ident: 隐藏所有的 LLVM/Clang 版本与签名指纹。
AppRetro_CFLAGS = -fobjc-arc -fvisibility=hidden -fno-objc-arc-exceptions -fno-exceptions -O3 -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-ident -include Obfuscation.h

# 🎯 极限静态破坏与防注入：
# -sectcreate __RESTRICT __restrict /dev/null : 操作系统级防御，内核检测到此段会彻底拒绝 DYLD_INSERT_LIBRARIES，完美防御 Substrate/Frida 注入，且兼容巨魔！
# -x, -dead_strip, -exported_symbol,_main : 清理所有局部与全局对外暴露符号。
AppRetro_LDFLAGS = -weak_framework MobileCoreServices -weak_framework StoreServices -Wl,-S -Wl,-x -Wl,-dead_strip -Wl,-exported_symbol,_main -Wl,-sectcreate,__RESTRICT,__restrict,/dev/null

AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk

before-all::
	@echo "Generating 0.5MB junk data to bloat binary..."
	@dd if=/dev/urandom of=junk.dat bs=1024 count=512 2>/dev/null
	@echo '.section __TEXT,__const' > junk.S
	@echo '.global _junk_data' >> junk.S
	@echo '.no_dead_strip _junk_data' >> junk.S
	@echo '_junk_data:' >> junk.S
	@echo '.incbin "junk.dat"' >> junk.S

after-package::
	@echo "Creating TrollStore .ipa..."
	@mkdir -p packages $(THEOS_STAGING_DIR)/Payload
	@cp -rp $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Applications/AppRetro.app $(THEOS_STAGING_DIR)/Payload
	@cd $(THEOS_STAGING_DIR); zip -qr AppRetro.ipa Payload; cd -;
	@mv $(THEOS_STAGING_DIR)/AppRetro.ipa packages/AppRetro.ipa
	@echo "Cleaning up junk files..."
	@rm -f junk.dat junk.S
