#include "byondapi/byondapi_cpp_wrappers.h"

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "Ws2_32.lib")
#else
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#endif

#include <cstring>

static int g_byond_port;

static bool InitSockets() {
#ifdef _WIN32
    static bool initialized = false;
    if (initialized)
        return true;

    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
        return false;

    initialized = true;
#endif
    return true;
}

static void CloseSocket(int sock) {
#ifdef _WIN32
    closesocket(sock);
#else
    close(sock);
#endif
}

extern "C" BYOND_EXPORT CByondValue Echo(u4c n, ByondValue v[]) {
    CByondValue ret;
    if (n != 1 || !v[0].IsStr()) {
        ByondValue_Clear(&ret);
        return ret;
    }
    ret = v[0];
    return ret;
}

extern "C" BYOND_EXPORT CByondValue SetBridgePort(u4c n, ByondValue v[]) {
    CByondValue ret;
	if(v[0].IsNum()) {
		g_byond_port = v[0].GetNum() + 1;
	}
    ret = v[0];
    return ret;
}

extern "C" BYOND_EXPORT CByondValue SendJSON(u4c n, ByondValue v[]) {
    CByondValue ret;

    if (!InitSockets()) {
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    if (n < 1 || !v[0].IsStr()) {
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    u4c buflen = 0;
    bool success = Byond_ToString(&v[0], nullptr, &buflen);

    if (!success && buflen == 0) {
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    char* buf = new char[buflen];

    success = Byond_ToString(&v[0], buf, &buflen);

    if (!success) {
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    u4c str_len = buflen - 1;

    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

    if (sock < 0) {
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));

    addr.sin_family = AF_INET;
    addr.sin_port = htons(3000);

#ifdef _WIN32
    inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
#else
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");
#endif

    if (connect(sock, (sockaddr*)&addr, sizeof(addr)) < 0) {
        CloseSocket(sock);
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

#ifdef _WIN32
    int sent = send(sock, buf, str_len, 0);
#else
    ssize_t sent = send(sock, buf, str_len, 0);
#endif

    CloseSocket(sock);
    delete[] buf;

    ByondValue_SetNum(&ret, sent == (int)str_len ? 1.0f : 0.0f);
    return ret;
}
