// This file contains defines allowing targeting byond versions newer than the supported

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 516
#define MIN_COMPILER_BUILD 1648
#if(DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD) && !defined(SPACEMAN_DMM) && !defined(OPENDREAM)
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 516.1648 or higher
#endif

// 516.1660 broke (x in vars), which breaks a lot of things.
#if(DM_VERSION == 516 && DM_BUILD == 1660)
#error This version of BYOND (516.1660) has a bug which prevents this codebase from loading properly. If possible, update your BYOND version. Otherwise, visit www.byond.com/download/build to download an older release.
#endif
