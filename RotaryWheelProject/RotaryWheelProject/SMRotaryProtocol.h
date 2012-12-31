//
//  SMRotaryProtocol.h
//  RotaryWheelProject
//
//  Created by Tim on 12/30/12.
//  Copyright (c) 2012 broderboy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMRotaryProtocol <NSObject>

- (void) wheelDidChangeValue:(NSString *)newValue;

@end
