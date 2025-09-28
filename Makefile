TARGET := iphone:clang:14.5:14.5

include $(THEOS)/makefiles/common.mk

TOOL_NAME = Resigner

Resigner_FILES = main.m
Resigner_CFLAGS = -fobjc-arc -Wno-unused-variable
Resigner_CODESIGN_FLAGS = -Sentitlements.plist
Resigner_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
