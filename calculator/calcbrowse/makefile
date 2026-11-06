NAME = BROWSER
DESCRIPTION = "TI-84 Plus CE Graphical Web Browser"
COMPRESSED = YES
ARCHIVED = YES
CFLAGS = -Wall -Wextra -Os -fno-omit-frame-pointer
CEDEV ?= $(HOME)/CEdev
CEDEV_TOOLCHAIN ?= $(CEDEV)
COMMENT ?= $(shell $(CEDEV)/bin/cedev-config --comment)
export PATH := $(CEDEV)/bin:$(PATH)
include $(shell $(CEDEV)/bin/cedev-config --makefile)
