//
//  SendAlarm.h
//  CS Heart
//
//  Created by Merijn van Tooren on 13/06/16.
//  Copyright © 2016 Sense Observation Systems BV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendAlarm : NSObject
+ (void)sendAlarmWithCompletionHandler:(void(^)())completionHandler;
@end
