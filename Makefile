# 仅保留 arm64，完美规避 arm64e 在 iOS 14 上的 dyld readClass 闪退问题
ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1

TARGET := iphone:clang:15.6:14.0
INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics
AppRetro_PRIVATE_FRAMEWORKS = MobileCoreServices

# 🎯 强力混淆与脱壳配置：
# -fvisibility=hidden: 隐藏所有方法与类符号
# -Wl,-S: 删除调试段
# -Wl,-x: 删除局部符号段
# -Wl,-dead_strip: 删除未使用的代码段
# -Wl,-no_fixup_chains: 解决 iOS14 dyld 加载崩溃
AppRetro_CFLAGS = -fobjc-arc -fvisibility=hidden
AppRetro_LDFLAGS = -Wl,-S -Wl,-x -Wl,-dead_strip -Wl,-no_fixup_chains

AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk

after-package::
	@echo "Creating TrollStore .ipa..."
	@mkdir -p packages $(THEOS_STAGING_DIR)/Payload
	@cp -rp $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Applications/AppRetro.app $(THEOS_STAGING_DIR)/Payload
	@cd $(THEOS_STAGING_DIR); zip -qr AppRetro.ipa Payload; cd -;
	@mv $(THEOS_STAGING_DIR)/AppRetro.ipa packages/AppRetro.ipa
