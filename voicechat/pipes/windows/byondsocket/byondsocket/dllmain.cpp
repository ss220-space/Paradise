// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#include "byondapi_cpp_wrappers.h"
#include <windows.h>
#include <cstring>

#pragma comment(lib, "byondapi.lib")

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
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

    // Connect to the named pipe (Windows equivalent of Unix domain socket)
    HANDLE hPipe = CreateFile(TEXT("\\\\.\\pipe\\byond_node"),
        GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        0,
        NULL);

    if (hPipe == INVALID_HANDLE_VALUE) {
        delete[] buf;
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }

    // Write to the pipe
    DWORD bytesWritten = 0;
    BOOL writeSuccess = WriteFile(hPipe, buf, str_len, &bytesWritten, NULL);

    CloseHandle(hPipe);
    delete[] buf;

    if (writeSuccess && bytesWritten == static_cast<DWORD>(str_len)) {
        ByondValue_SetNum(&ret, 1.0f);
        return ret;
    }
    else {
        ByondValue_SetNum(&ret, 0.0f);
        return ret;
    }
}
