#基本
CC = g++
CFLAGS=-Wall -Wno-deprecated -g -std=c++11
LDFLAGS= -lcrypto -lbase -lpthread -lprotobuf-lite -lslog -llog4cxx -lcurl -loss_c_sdk -lmxml -lapr-1 -laprutil-1
ifeq ($(shell uname), Darwin)
#CFLAGS := $(CFLAGS) -Os -framework Cocoa
LDFLAGS := $(LDFLAGS) -Os -framework Cocoa
endif
LN=/bin/ln -s 
AR=ar
CP=/bin/cp
RM=-/bin/rm -rf
ARCH=PC

#链接库名
LIB_NAME=
#链接库版本
LIB_VER=1.0.0

# 二进制目标
BIN=test

#源文件目录
SrcDir= .
#头文件目录
IncDir= . /usr/include/openssl ../base ../base/jsoncpp ../base/pb/protocol ../base/pb /usr/local/include/oss_c_sdk /usr/include/apr-1
#连接库目录
LibDir= /usr/lib64/openssl/engines ../base ../base/slog/lib ../base/pb/lib/mac ../protobuf/lib /usr/local/lib /usr/local/apr/lib 

SRCS=$(foreach dir,$(SrcDir),$(wildcard $(dir)/*.cpp))
INCS=$(foreach dir,$(IncDir),$(addprefix -I,$(dir)))
LINKS=$(foreach dir,$(LibDir),$(addprefix -L,$(dir)))
CFLAGS := $(CFLAGS) $(INCS)
LDFLAGS:= $(LINKS) $(LDFLAGS) -Wl,-rpath=/home/neil/project/space/server/src/base/slog/lib

#OBJS = $(SRCS:%.cpp=%.o) playsound.o
OBJS = $(SRCS:%.cpp=%.o) 
.PHONY:all clean

all:$(BIN)
#$(BIN):$(OBJS) playsound.o
$(BIN):$(OBJS) ../base/libbase.a
	$(CC) -o $(BIN) $(OBJS) $(LDFLAGS)
	@echo " OK!\tComplie $@ "

%.o:%.cpp
	@echo "[$(ARCH)] \t\tCompileing $@..."
	@$(CC) $(CFLAGS) -c $< -o $@
ifeq ($(shell uname), Darwin)
playsound.o:playsound.mm
	@echo "[$(ARCH)] \t\tCompileing $@..."
	$(CC) $(CFLAGS) -c $< -o $@
else
playsound.o:playsound.c
	@echo "[$(ARCH)] \t\tCompileing $@..."
	$(CC) $(CFLAGS) -c $< -o $@
endif

.PHONY: clean
clean:
	@echo "[$(ARCH)] \tCleaning files..."
	@$(RM) $(OBJS) $(BIN)
