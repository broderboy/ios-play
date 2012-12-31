//
//  SMRotaryWheel.h
//  RotaryWheelProject
//
//  Created by Tim on 12/30/12.
//  Copyright (c) 2012 broderboy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMRotaryProtocol.h"
#import "SMSector.h"

@interface SMRotaryWheel : UIControl

@property (weak) id <SMRotaryProtocol> delegate;
@property (nonatomic, strong) UIView *container;
@property int numberOfSections;
@property CGAffineTransform startTransform;
@property (nonatomic, strong) NSMutableArray *sectors;
@property int currentSector;

-(id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)numbeOfSections;
-(void) rotate;

@end
