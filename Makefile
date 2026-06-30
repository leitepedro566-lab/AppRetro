TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics

# 【核心修复】：移除了 AppStoreDaemon 和 StoreServices。
# 因为我们在代码中是用 dlopen 动态加载的，不需要在编译时静态链接。
AppRetro_PRIVATE_FRAMEWORKS = MobileCoreServices

AppRetro_CFLAGS = -fobjc-arc
AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk
