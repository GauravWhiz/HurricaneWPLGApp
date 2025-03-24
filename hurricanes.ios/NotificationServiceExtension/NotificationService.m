//
//  NotificationService.m
//  DEMO Notification Service Extension
//
//  Created by Sachin Ahuja on 07/05/19.
//  Copyright © 2019 PNSDigital. All rights reserved.
//

#import "NotificationService.h"
static NSString *const AppboyAPNSDictionaryKey = @"ab";
static NSString *const AppboyAPNSDictionaryAttachmentKey = @"att";
static NSString *const AppboyAPNSDictionaryAttachmentURLKey = @"url";
static NSString *const AppboyAPNSDictionaryAttachmentTypeKey = @"type";

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) UNMutableNotificationContent *originalContent;
@property BOOL abortOnAttachmentFailure;
@property NSURLSession *session;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    self.originalContent = [request.content mutableCopy];
    self.abortOnAttachmentFailure = NO;
      
      NSMutableArray *attachments = [NSMutableArray arrayWithCapacity:1];
      NSDictionary *userInfo = request.content.userInfo;
      
      // Check that the push is from Braze
      if (userInfo == nil || userInfo[AppboyAPNSDictionaryKey] == nil) {
          
        // Push not from Braze
        // Note: if you have other push senders and want to handler here, fork your code here to handle
          if (userInfo != nil){
              NSString *alert = userInfo[@"aps"][@"alert"];
              self.bestAttemptContent.body = alert;
              if ([alert rangeOfString:@"DT:"].location != NSNotFound){
                 NSArray *words = [alert componentsSeparatedByString:@" "];
                  for (NSString *word in words){
                      if ([word rangeOfString:@"DT:"].location != NSNotFound){
                          NSString *strTimestamp = [word componentsSeparatedByString:@":"].lastObject;
                          if (strTimestamp != nil){
                              double timestamp = [strTimestamp doubleValue];
                              NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                              [dateFormatter setDateFormat:@"h:mm a zzz"];
                              NSDate *utc = [NSDate dateWithTimeIntervalSince1970:timestamp];
                              [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                              NSString *localTime = [dateFormatter stringFromDate:utc];
                              NSString *stringToReplace = [NSString stringWithFormat:@"DT:%@",strTimestamp];
                              self.bestAttemptContent.body = [alert stringByReplacingOccurrencesOfString:stringToReplace withString:localTime];
                          }
                      }
                  }
              }
          }
          
          self.contentHandler(self.bestAttemptContent);
       
      } else {
          
          // Push is from Braze
          
          NSDictionary *appboyPayload = userInfo[AppboyAPNSDictionaryKey];
           
           // Check that the push has an attachment
           if (appboyPayload[AppboyAPNSDictionaryAttachmentKey] == nil) {
             // Push has no attachment
             [self displayOriginalContent];
             return;
           }
           
           NSDictionary *attachmentPayload = appboyPayload[AppboyAPNSDictionaryAttachmentKey];
           
           // Check that the attachment has a URL
           if (attachmentPayload[AppboyAPNSDictionaryAttachmentURLKey] == nil) {
             NSLog(@"Push attachment has no url.");
             [self displayOriginalContent];
             return;
           }
           
           NSString *attachmentURLString = attachmentPayload[AppboyAPNSDictionaryAttachmentURLKey];
           
           // Get the type
           if (attachmentPayload[AppboyAPNSDictionaryAttachmentTypeKey] == nil) {
            // Push attachment has no type
             [self displayOriginalContent];
             return;
           }
           
           NSString *attachmentType = attachmentPayload[AppboyAPNSDictionaryAttachmentTypeKey];
           
           NSString *fileSuffix = [@"." stringByAppendingString:attachmentType];
           
           // Download, store, and attach the content to the notification
           if (attachmentURLString) {
             NSURL *attachmentURL = [NSURL URLWithString:attachmentURLString];
             self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
             [[self.session downloadTaskWithURL:attachmentURL
                         completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                           if (error != nil) {
                             [self.class logMessage:@"Error fetching attachment, displaying content unaltered: %@", [error localizedDescription]];
                             [self displayOriginalContent];
                             return;
                           } else {
                             [self.class logMessage:@"Data fetched from server, processing with temporary file url %@", [temporaryFileLocation absoluteString]];

                             NSFileManager *fileManager = [NSFileManager defaultManager];
                             NSURL *typedAttachmentURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileSuffix]];
                             [fileManager moveItemAtURL:temporaryFileLocation toURL:typedAttachmentURL error:&error];
                             
                             NSError *attachError = nil;
                             UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:typedAttachmentURL options:nil error:&attachError];
                             if (attachment == nil) {
                               [self.class logMessage:@"Attachment returned error: %@", [attachError localizedDescription]];
                               [self displayOriginalContent];
                               return;
                             }

                             attachments[0] = attachment;
                             self.bestAttemptContent.attachments = attachments;
                             self.contentHandler(self.bestAttemptContent);
                             [self.session finishTasksAndInvalidate];
                           }
                         }] resume];
           }
      }
    
    
    
   
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

- (void)displayOriginalContent {
  self.contentHandler(self.originalContent);
}

+ (void)logMessage:(NSString *)message, ... {
  va_list args;
  va_start(args, message);
  NSLog(@"%@", [[NSString alloc] initWithFormat:[@"[APPBOY] " stringByAppendingString:message] arguments:args]);
  va_end(args);
}

@end
