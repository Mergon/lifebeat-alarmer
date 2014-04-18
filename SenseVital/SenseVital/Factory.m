//
//  Factory.m
//  SenseVital
//
//  Created by Pim Nijdam on 18/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import "Factory.h"

@implementation Factory

//Singleton instance
static Factory* sharedFactoryInstance = nil;

+ (Factory*) sharedFactory {
	if (sharedFactoryInstance == nil) {
		sharedFactoryInstance = [[super allocWithZone:NULL] init];
	}
	return sharedFactoryInstance;
}

//override to ensure singleton
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedFactory];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (Factory*) init {
    self = [super init];
    if (self) {
        _csVitalConnectSensor = [[CSVitalConnectSensor alloc] init];
    }
    return self;
}


@end
