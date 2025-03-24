//
//  BlueconiciOSPlugin.h
//  Newsreader
//
//  Created by Bhavya on 23/03/21.
//  Copyright © 2021 Graham Media Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BlueConicClient/BlueConicClient-Swift.h>
#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface BlueconicATTPlugin : UIViewController <BlueConicPlugin>

// Blueconic delegate methods
- (instancetype) initWithClient: (BlueConic *)client context:(InteractionContext *)context;
- (void) onLoad;
- (void) onDestroy;

@end

NS_ASSUME_NONNULL_END
