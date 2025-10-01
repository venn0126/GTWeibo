TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = gtweibo

#忽略OC警告，未使用的方法或者未使用的变量，避免警告导致编译不过
$(TWEAK_NAME)_OBJCFLAGS +=  -Wno-deprecated-declarations -Wno-unused-variable -include Prefix.pch
# 忽略C警告，未使用的方法或者未使用的变量，避免警告导致编译不过
$(TWEAK_NAME)_CFLAGS += -Wno-error=unused-variable -Wno-error=unused-function -include Prefix.pch


$(TWEAK_NAME)_FILES += $(wildcard src/Tool/*/*.m) $(wildcard src/Tool/*.m)


$(TWEAK_NAME)_FILES += Tweak.x
$(TWEAK_NAME)_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
