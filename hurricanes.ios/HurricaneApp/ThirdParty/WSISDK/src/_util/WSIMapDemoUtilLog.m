// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

/*
 Override NSLog to use printf.
 With Xcode 9+, the console log is often filled with internal OS logs unless
 you set OS_ACTIVITY_MODE to "disable" for the target scheme. But that also
 causes NSLogs to be filtered out unless we do the printf trick here.
 Our NSLog override below will catch *all* calls to NSLog from this app but
 also from frameworks.
 */
 
#import "WSIMapDemoUtilLog.h"
#import "WSIMapDemoUtilTime.h"

/*
 If 1, we use printf to send the final NSLog string to the console so those show
 even if OS_ACTIVITY_MODE is set to disable (no idea why Apple made that disable
 NSLog as well as internal logs...
 */
#define WMD_USE_PRINTF 1
#if !WMD_USE_PRINTF
static void (*originalNSLog)(NSString *, ...);
#endif


#define APP_LOG_FUNCTIONS           0   // if 1, includes function name, line # in AppLogXXX - bit spammy

static NSString * kWSIPrefix = @"WSI DEM";

void WMDUtilLog(NSString *context, NSString *func, int line, NSString *messageFormat,...)
{
    va_list args;
    va_start(args,messageFormat);

    NSString *message = [[NSString alloc] initWithFormat:messageFormat arguments:args];
    
    va_end(args);
    
    if (context && context.length > 0)
        context = [NSString stringWithFormat:@"[%@ %@]:", kWSIPrefix, context];
    else
        context = [NSString stringWithFormat:@"[%@]:", kWSIPrefix];
    
    // Note: We override NSLog in MALLogger to a) log the string to a file b) log the string using printf.
    #if APP_LOG_FUNCTIONS
    NSLog(@"%@ %@ (%@,%d)",context,message,func,line);
    #else
    NSLog(@"%@ %@",context,message);
    #endif
}



void mlPrintString(NSString *message)
{
    #if WMD_USE_PRINTF
    NSString *currentTimeString = [WSIMapDemoUtilTime nowTimeStringWithFormat:@"HH:mm:ss.sss"];
    const char *szCurrentTimeString = [currentTimeString cStringUsingEncoding:NSUTF8StringEncoding];
    const char *szThreadString = [NSThread isMainThread] ? "[MAIN]" : "[BACK]";
    const char *szMessage = [message cStringUsingEncoding:NSUTF8StringEncoding];
    printf("%s %s %s\n", szCurrentTimeString, szThreadString, szMessage);
    #else
    (*originalNSLog)(@"%@", message);
    #endif
}


@interface WSIMapSDKLogger : NSObject
@end


@implementation WSIMapSDKLogger

- (instancetype)init
{
    if (self = [super init])
    {
        #if !WMD_USE_PRINTF
        originalNSLog = (void (*)(NSString *, ...))dlsym(RTLD_NEXT, "NSLog");
        #endif
    }
    return self;
}


+ (instancetype)sharedInstance
{
    static id _cachedInstance = nil;
    
    @synchronized(self)
    {
        if (!_cachedInstance)
        {
            _cachedInstance = [[super allocWithZone:nil] init];
        }
        return _cachedInstance;
    }
}


- (void)logv:(NSString *)string
{
    @synchronized(self)
    {
        // here you could filter out specific (annoying) logs from frameworks etc.
        if ([string hasPrefix:@"[HockeySDK] WARNING:"])
            return;
        mlPrintString(string);
    }
}


void NSLog(NSString *format, ...)
{
    va_list arguments;
    
    va_start(arguments, format);
    NSString *stringWithArguments = [[NSString alloc] initWithFormat: format arguments: arguments];
    va_end(arguments);
    [[WSIMapSDKLogger sharedInstance] logv:stringWithArguments];
}

@end
