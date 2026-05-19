# Voice Chat Socket Library - Cross-Platform Build Guide

This library enables BYOND to communicate with Node.js servers via:
- **Windows**: TCP sockets (localhost:27000)
- **Unix/Linux/macOS**: Unix domain sockets (byond_node.sock)

## Directory Structure

```
voicechat/pipes/
├── main.cpp                 # Cross-platform source (NEW)
├── Makefile                 # Cross-platform build config (NEW)
├── BUILD.md                 # This file
├── unix/
│   ├── main.cpp             # Original Unix version (can be removed)
│   ├── makefile             # Original Unix makefile (can be removed)
│   ├── byondapi/
│   │   ├── byondapi.h
│   │   ├── byondapi_cpp_wrappers.h
│   │   ├── byondapi_cpp_wrappers.cpp
│   │   └── byondapi_cpp_wrappers.o
│   └── byondsocket.so       # Unix compiled library (output)
└── windows/
    ├── byondapi_cpp_wrappers.o  # Windows object file
    ├── main.o                    # Windows object file
    └── byondsocket.dll           # Windows compiled library (output)
```

## Build Instructions

### Linux / Unix

```bash
cd voicechat/pipes
make TGS_INSTANCE_ROOT=/path/to/tgs
```

Output: `unix/byondsocket.so`

### macOS

```bash
cd voicechat/pipes
make TGS_INSTANCE_ROOT=/path/to/tgs
```

Output: `unix/byondsocket.dylib`

### Windows (with Visual Studio / MSVC)

```cmd
cd voicechat\pipes
cl /Od /W3 /DLL /D_CRT_SECURE_NO_WARNINGS main.cpp unix/byondapi/byondapi_cpp_wrappers.cpp /Fe:windows/byondsocket.dll ws2_32.lib
```

Output: `windows/byondsocket.dll`

### Windows (with MinGW)

```bash
cd voicechat/pipes
g++ -shared -mwindows main.cpp unix/byondapi/byondapi_cpp_wrappers.cpp -lws2_32 -L.\windows\byondapi -lbyondapi -o windows/byondsocket.dll
```

Output: `windows/byondsocket.dll`

## Implementation Details

### Windows (TCP Sockets)

The Windows version connects to the Node.js server via TCP:
- **Host**: `127.0.0.1`
- **Port**: `27000`
- **Protocol**: TCP/IP
- **Connection**: Established for each message send

```cpp
// Windows flow:
1. Initialize Winsock2
2. Create AF_INET socket (TCP)
3. Connect to 127.0.0.1:27000
4. Send JSON data
5. Close socket
6. Cleanup Winsock2
```

### Unix/Linux/macOS (Unix Domain Sockets)

The Unix version connects via Unix domain sockets:
- **Socket File**: `byond_node.sock`
- **Location**: Current working directory
- **Connection**: Per-message like TCP version

```cpp
// Unix flow:
1. Create AF_UNIX socket
2. Connect to byond_node.sock
3. Send JSON data
4. Close socket
```

## Requirements

### Linux
- BYOND SDK (libbyond.so)
- GCC/G++ compiler
- libc development headers
- 32-bit development libraries (for -m32)

### macOS
- BYOND SDK (libbyond.dylib)
- Clang compiler
- 32-bit support (if compiling 32-bit)

### Windows
- BYOND SDK headers
- Visual Studio (MSVC) or MinGW compiler
- Windows SDK for winsock2

## Troubleshooting

### "Cannot find -lbyond" (Linux)
- Set `TGS_INSTANCE_ROOT` to point to TGS installation
- Or manually edit the Makefile to point to BYOND path

### "Port already in use" (Windows)
- Check if another instance of Node.js is running
- Change BYOND_SERVER_PORT in ByondServer.js if needed

### "Connection refused"
- Ensure Node.js server is running on port 27000
- On Windows, check firewall settings for port 27000
- On Unix, verify byond_node.sock exists in the correct directory

## Compatibility

| OS | Support | Transport | Status |
|---|---------|-----------|--------|
| Linux (32-bit) | Full | Unix socket | ✅ Tested |
| Linux (64-bit) | Partial | Unix socket | ⚠️ May require 32-bit libs |
| macOS (Intel) | Full | Unix socket | ✅ Tested |
| macOS (ARM) | Unknown | Unix socket | ❓ Needs verification |
| Windows | Full | TCP socket | ✅ New |
| FreeBSD | Partial | Unix socket | ❓ Untested |

## Future Improvements

- [ ] Auto-detection of compilation flags
- [ ] 64-bit support
- [ ] Fallback TCP mode for Unix systems
- [ ] Connection pooling
- [ ] Async JSON sending
