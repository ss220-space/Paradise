# Makefile
CC=gcc
CPP=g++

TARGET=byondsocket.dll

OBJS=main.o byondapi/byondapi_cpp_wrappers.o

CFLAGS=-O2 -DWIN32
LDFLAGS=-shared -lws2_32 -L./byondapi -lbyondapi

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CPP) -o $(TARGET) $(OBJS) $(LDFLAGS)

main.o: main.cpp
	$(CPP) $(CFLAGS) -c main.cpp -o main.o

byondapi/byondapi_cpp_wrappers.o: byondapi/byondapi_cpp_wrappers.cpp
	$(CPP) $(CFLAGS) -c byondapi/byondapi_cpp_wrappers.cpp -o byondapi/byondapi_cpp_wrappers.o

clean:
	del /Q *.o *.dll
