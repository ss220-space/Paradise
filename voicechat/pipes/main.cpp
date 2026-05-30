#include "unix/byondapi/byondapi_cpp_wrappers.h"

#ifdef _WIN32
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #pragma comment(lib, "ws2_32.lib")
    #define CLOSE_SOCKET closesocket
    typedef int socklen_t;
#else
    #include <sys/socket.h>
    #include <sys/un.h>
    #include <unistd.h>
    #include <arpa/inet.h>
    #define CLOSE_SOCKET close
    #define SOCKET_ERROR -1
    #define INVALID_SOCKET -1
    typedef int SOCKET;
#endif

#include <cstring>
#include <cstdlib>

extern "C" BYOND_EXPORT CByondValue Echo(u4c n, ByondValue v[]) {
    CByondValue ret;
    if (n != 1 || !v[0].IsStr()) {
        ByondValue_Clear(&ret);
        return ret;
    }
    ret = v[0];
    return ret;
}

extern "C" BYOND_EXPORT CByondValue SendJSON(u4c n, ByondValue v[]) {
    CByondValue ret;
    if (n < 1 || !v[0].IsStr()) {
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    // Query the required buffer size first
    u4c buflen = 0;
    bool success = Byond_ToString(&v[0], nullptr, &buflen);
    if (!success && buflen == 0) {
        // Error querying size
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    // Allocate buffer and get the string
    char* buf = new char[buflen];
    success = Byond_ToString(&v[0], buf, &buflen);
    if (!success) {
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    // buflen now holds the actual length +1 (null terminator), so str_len is buflen -1
    u4c str_len = buflen - 1;

    SOCKET sock;

#ifdef _WIN32
    // Windows: Use TCP socket to localhost:27000
    static bool wsa_initialized = false;
    if (!wsa_initialized) {
        WSADATA wsaData;
        if (WSAStartup(MAKEWORD(2, 2), &wsaData) == 0) {
            wsa_initialized = true;
        }
    }

    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == INVALID_SOCKET) {
        WSACleanup();
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(27000);
    inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

    if (connect(sock, (struct sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR) {
        CLOSE_SOCKET(sock);
        WSACleanup();
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    int sent = send(sock, buf, str_len, 0);
    CLOSE_SOCKET(sock);
    WSACleanup();

    if (sent == static_cast<int>(str_len)) {
        delete[] buf;
        ByondValue_SetNum(&ret, 1.0f);
        return ret;
    } else {
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }
#else
    // Unix: Use Unix domain socket
    sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock == INVALID_SOCKET) {
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, "byond_node.sock", sizeof(addr.sun_path) - 1);

    if (connect(sock, (struct sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR) {
        CLOSE_SOCKET(sock);
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    ssize_t sent = write(sock, buf, str_len);
    CLOSE_SOCKET(sock);
    delete[] buf;

    if (sent == static_cast<ssize_t>(str_len)) {
        ByondValue_SetNum(&ret, 1.0f);
        return ret;
    } else {
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }
#endif
}
