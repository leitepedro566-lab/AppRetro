TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics
AppRetro_PRIVATE_FRAMEWORKS = MobileCoreServices AppStoreDaemon StoreServices
AppRetro_CFLAGS = -fobjc-arc
AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk
