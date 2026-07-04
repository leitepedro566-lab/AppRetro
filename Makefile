DEBUG = 0
FINALPACKAGE = 1

ARCHS := arm64 arm64e
TARGET := iphone:clang:15.6:14.0

INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m junk.S
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics

AppRetro_CFLAGS = -fobjc-arc -fvisibility=hidden -include Obfuscation.h

# 🎯 核心改动：在尾部追加了 -Wl,-exported_symbol,_main
# 这会强制链接器丢弃除了启动函数外的所有导出符号，配合 -x 局部符号抹除，能让符号表彻底变为空
AppRetro_LDFLAGS = -weak_framework MobileCoreServices -weak_framework StoreServices -Wl,-S -Wl,-x -Wl,-dead_strip -Wl,-exported_symbol,_main

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
