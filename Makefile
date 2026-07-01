DEBUG = 0
FINALPACKAGE = 1

ARCHS := arm64 arm64e
TARGET := iphone:clang:15.6:14.0

INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

# 🎯 注意：文件列表中新增了我们将要动态生成的 junk.S
AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m junk.S
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics

AppRetro_CFLAGS = -fobjc-arc -fvisibility=hidden -include Obfuscation.h
# 🎯 LDFLAGS 中已包含 -Wl,-S -Wl,-x -Wl,-dead_strip（移除局部/全局符号表，并剔除无用代码）
AppRetro_LDFLAGS = -weak_framework MobileCoreServices -weak_framework StoreServices -Wl,-S -Wl,-x -Wl,-dead_strip

AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk

# 🎯 编译前置 Hook：自动生成 0.5MB 随机垃圾数据，并转为汇编代码强制打入二进制常量区
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
