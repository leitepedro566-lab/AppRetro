DEBUG = 0
FINALPACKAGE = 1

# 成功迎回 arm64e！
ARCHS := arm64 arm64e
TARGET := iphone:clang:15.6:14.0

INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics

# 🎯 究极混淆注入：
# -include Obfuscation.h: 全局自动注入混淆宏
# -fvisibility=hidden: 隐藏所有公开类和方法的符号
# -Wl,-S -Wl,-x -Wl,-dead_strip: 彻底剥离所有调试段、本地符号段，让 Hopper 看到的全是 sub_xxx
AppRetro_CFLAGS = -fobjc-arc -fvisibility=hidden -include Obfuscation.h

# 🎯 解决 iOS14 arm64e 闪退核心：将强依赖的 PrivateFramework 改为弱链接 (-weak_framework)
AppRetro_LDFLAGS = -weak_framework MobileCoreServices -Wl,-S -Wl,-x -Wl,-dead_strip

AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk

after-package::
	@echo "Creating TrollStore .ipa..."
	@mkdir -p packages $(THEOS_STAGING_DIR)/Payload
	@cp -rp $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Applications/AppRetro.app $(THEOS_STAGING_DIR)/Payload
	@cd $(THEOS_STAGING_DIR); zip -qr AppRetro.ipa Payload; cd -;
	@mv $(THEOS_STAGING_DIR)/AppRetro.ipa packages/AppRetro.ipa
