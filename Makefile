GO_EASY_ON_ME=1
include theos/makefiles/common.mk

TWEAK_NAME = snapshotter
snapshotter_FILES = Tweak.xm
snapshotter_PRIVATE_FRAMEWORKS= AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
