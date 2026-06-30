# 1. 指定架构 (arm64 兼容巨魔)
ARCHS := arm64 arm64e

# 2. 【核心修复】：明确使用 iOS 15.6 SDK 编译，部署目标 iOS 14.0。
# 这样即便在 macos-latest (带新版编译器) 下，Theos 也会调用兼容的参数链。
TARGET := iphone:clang:15.6:14.0

INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics

# 3. 继续使用动态加载不需要静态链接这几个库，但基础配置和 TrollCM 保持同频
AppRetro_PRIVATE_FRAMEWORKS = MobileCoreServices

AppRetro_CFLAGS = -fobjc-arc
AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk

# 4. 【额外加成】：利用 Theos 钩子自动转 ipa (参考 TrollCM 优雅的做法)
after-package::
	@echo "Creating TrollStore .ipa..."
	@mkdir -p packages $(THEOS_STAGING_DIR)/Payload
	@cp -rp $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Applications/AppRetro.app $(THEOS_STAGING_DIR)/Payload
	@cd $(THEOS_STAGING_DIR); zip -qr AppRetro.ipa Payload; cd -;
	@mv $(THEOS_STAGING_DIR)/AppRetro.ipa packages/AppRetro.ipa
