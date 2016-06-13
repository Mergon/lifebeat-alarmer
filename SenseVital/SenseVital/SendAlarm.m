//
//  SendAlarm.m
//  CS Heart
//
//  Created by Merijn van Tooren on 13/06/16.
//  Copyright © 2016 Sense Observation Systems BV. All rights reserved.
//

#import "SendAlarm.h"

@implementation SendAlarm

+ (void)sendAlarmWithCompletionHandler:(void(^)())completionHandler { // MERRY HACK: Alarm sending code here
    NSURL *alarmURL = [NSURL URLWithString:@"http://test.ask-cs.com/~jordi/medical-demo/alarm_medics.php"];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:alarmURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        completionHandler();
    }];
}

@end
