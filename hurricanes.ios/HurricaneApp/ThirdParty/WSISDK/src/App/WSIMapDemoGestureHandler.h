// IBM Confidential
// Copyright IBM Corp. 2016, 2021. Copyright WSI Corporation 1998, 2015.

@class WSIMapDemoCalloutHandler;
@interface WSIMapDemoGestureHandler : NSObject <WSIMapSDKGestureDelegate>
- (instancetype)initWithCalloutHandler:(WSIMapDemoCalloutHandler *)calloutHandler;
@end
