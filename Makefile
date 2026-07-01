DEBUG = 0
FINALPACKAGE = 1

ARCHS := arm64 arm64e
TARGET := iphone:clang:15.6:14.0

INSTALL_TARGET_PROCESSES = AppRetro

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = AppRetro

AppRetro_FILES = main.m ARAppDelegate.m ARRootViewController.m ARVersionViewController.m ARDowngradeManager.m
AppRetro_FRAMEWORKS = UIKit Foundation CoreGraphics

AppRetro_CFLAGS = -fobjc-arc -fvisibility=hidden -include Obfuscation.h
AppRetro_LDFLAGS = -weak_framework MobileCoreServices -weak_framework StoreServices -Wl,-S -Wl,-x -Wl,-dead_strip

AppRetro_CODESIGN_FLAGS = -S$(APPLICATION_NAME).entitlements

include $(THEOS_MAKE_PATH)/application.mk

after-package::
	@echo "Creating TrollStore .ipa..."
	@mkdir -p packages $(THEOS_STAGING_DIR)/Payload
	@cp -rp $(THEOS_STAGING_DIR)$(THEOS_PACKAGE_INSTALL_PREFIX)/Applications/AppRetro.app $(THEOS_STAGING_DIR)/Payload
	@cd $(THEOS_STAGING_DIR); zip -qr AppRetro.ipa Payload; cd -;
	@mv $(THEOS_STAGING_DIR)/AppRetro.ipa packages/AppRetro.ipa
