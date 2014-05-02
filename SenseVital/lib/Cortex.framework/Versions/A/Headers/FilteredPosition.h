//
//  FilteredPosition.h
//  Intellisense
//
//  Created by Pim Nijdam on 3/28/13.
//  Copyright (c) 2013 Sense Observation Systems BV. All rights reserved.
//

#import "AIModule.h"

/** Wrapper for the PositionFilter AI Module.
 * To use this class just instantiate it and enable the position sensor. It will save the filtered position stream to a new position sensor.
 */
@interface FilteredPosition : AIModule

@end
