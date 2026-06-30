# 明确指定基于 14.0 SDK 编译
TARGET := iphone:clang:14.0:14.0
INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics
AppRetro_PRIVATE_FRAMEWORKS = MobileCoreServices

AppRetro_CFLAGS = -fobjc-arc
# 【核心修复 2】：强制调用经典链接器，禁用可能导致 iOS 14 崩溃的新版指针特性
AppRetro_LDFLAGS = -Wl,-ld_classic

AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk
