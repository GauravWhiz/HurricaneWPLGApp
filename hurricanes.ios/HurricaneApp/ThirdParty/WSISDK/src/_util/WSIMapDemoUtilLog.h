// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

#define WMD_LOG_DELEGATES               0
#define WMD_LOG_DELEGATES_UI            0
#define WSI_LOG_NETWORK                 0
#define WSI_LOG_SETTINGS                0

// It's expected that the user call WMDLogXXX with either a single string, or a string that's a format
// and then a set of varargs to get printed using that format).
// We collect other compile-time context information and pass that on to the utility function.

extern void WMDUtilLog(NSString *context, NSString *func, int line, NSString *format, ...);
#define WMDLogStandard(context,...) WMDUtilLog(context,[NSString stringWithUTF8String:__PRETTY_FUNCTION__],__LINE__,__VA_ARGS__)


#if WMD_LOG_DELEGATES
#pragma message("WARNING: WMD_LOG_DELEGATES ENABLED!")
#define DemoLogDelegate(...)  WMDLogStandard(@"Delegate",__VA_ARGS__)
#else
#define DemoLogDelegate(...)
#endif

#if WMD_LOG_DELEGATES_UI
#pragma message("WARNING: WMD_LOG_DELEGATES_UI ENABLED!")
#define DemoLogUIDelegate(...)  WMDLogStandard(@"UI Delegate",__VA_ARGS__)
#else
#define DemoLogUIDelegate(...)
#endif

// always enabled?
#define WMDLog(...)         WMDLogStandard(@"",__VA_ARGS__)
#define WMDLogError(...)    WMDLogStandard(@"ERROR",__VA_ARGS__)
#define WMDLogWarning(...)  WMDLogStandard(@"WARNING",__VA_ARGS__)
