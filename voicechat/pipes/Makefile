# Cross-Platform Makefile for Voice Chat BYOND Socket Library
# Supports: Linux (Unix), macOS, Windows (MSVC/MinGW)

UNAME_S := $(shell uname -s)
BYOND_VERSION ?= 515
TGS_INSTANCE_ROOT ?= /opt/byond

ifeq ($(UNAME_S),Linux)
    PLATFORM = linux
    BYOND_PATH = $(TGS_INSTANCE_ROOT)/Byond/$(BYOND_VERSION)/byond/bin
    CC = gcc
    CPP = g++
    CFLAGS = -m32 -pthread -g -Wall -Wno-deprecated -O3 -fno-strict-aliasing
    LDFLAGS = -m32 -shared $(BYOND_PATH)/libbyond.so
    TARGET_LIB = unix/byondsocket.so
    RM = rm -f
endif

ifeq ($(UNAME_S),Darwin)
    PLATFORM = macos
    BYOND_PATH = $(TGS_INSTANCE_ROOT)/Byond/$(BYOND_VERSION)/byond/bin
    CC = clang
    CPP = clang++
    CFLAGS = -m32 -pthread -g -Wall -O3 -fno-strict-aliasing -fPIC
    LDFLAGS = -m32 -shared $(BYOND_PATH)/libbyond.dylib
    TARGET_LIB = unix/byondsocket.dylib
    RM = rm -f
endif

ifeq ($(OS),Windows_NT)
    PLATFORM = windows
    CC = cl
    CPP = cl
    CFLAGS = /Od /W3 /D_CRT_SECURE_NO_WARNINGS
    LDFLAGS = /DLL /SUBSYSTEM:WINDOWS ws2_32.lib
    TARGET_LIB = windows/byondsocket.dll
    RM = del
endif

# If platform not detected, assume Linux
ifndef PLATFORM
    PLATFORM = linux
    BYOND_PATH ?= /opt/byond/Byond/$(BYOND_VERSION)/byond/bin
    CC = gcc
    CPP = g++
    CFLAGS = -m32 -pthread -g -Wall -Wno-deprecated -O3 -fno-strict-aliasing
    LDFLAGS = -m32 -shared $(BYOND_PATH)/libbyond.so
    TARGET_LIB = unix/byondsocket.so
    RM = rm -f
endif

OBJS = main.o unix/byondapi/byondapi_cpp_wrappers.o

.PHONY: all clean

all: $(TARGET_LIB)

$(TARGET_LIB): $(OBJS)
	@mkdir -p $(dir $@)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.cpp
	$(CPP) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

clean:
	-$(RM) $(TARGET_LIB) $(OBJS)

help:
	@echo "Cross-Platform BYOND Voice Chat Socket Library"
	@echo ""
	@echo "Usage:"
	@echo "  make                          # Build for current platform"
	@echo "  make TGS_INSTANCE_ROOT=/path  # Specify BYOND path"
	@echo "  make clean                    # Clean build artifacts"
	@echo ""
	@echo "Detected Platform: $(PLATFORM)"
	@echo "Target Library: $(TARGET_LIB)"
	@echo ""
	@echo "For manual compilation:"
	@echo "  Linux/macOS:  g++ -m32 -shared -fPIC main.cpp unix/byondapi/byondapi_cpp_wrappers.cpp -o unix/byondsocket.so"
	@echo "  Windows (MSVC): cl /Od /W3 /DLL main.cpp unix/byondapi/byondapi_cpp_wrappers.cpp ws2_32.lib"
	@echo "  Windows (MinGW): g++ -shared -mwindows main.cpp unix/byondapi/byondapi_cpp_wrappers.cpp -lws2_32 -o windows/byondsocket.dll"
