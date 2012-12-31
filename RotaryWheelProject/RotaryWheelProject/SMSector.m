//
//  SMSector.m
//  RotaryWheelProject
//
//  Created by Tim on 12/30/12.
//  Copyright (c) 2012 broderboy. All rights reserved.
//

#import "SMSector.h"

@implementation SMSector

@synthesize midValue, maxValue, minValue, sector;

- (NSString *) description
{
    return [NSString stringWithFormat:@"%f | %f, %f, %f", self.sector, self.minValue, self.midValue, self.maxValue];
}

@end
