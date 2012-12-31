//
//  SMViewController.m
//  RotaryWheelProject
//
//  Created by Tim on 12/30/12.
//  Copyright (c) 2012 broderboy. All rights reserved.
//

#import "SMViewController.h"
#import "SMRotaryWheel.h"

@interface SMViewController ()

@end

@implementation SMViewController

@synthesize sectorLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    sectorLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 350, 120, 30)];
    sectorLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:sectorLabel];    
    
    SMRotaryWheel *wheel = [[SMRotaryWheel alloc] initWithFrame:CGRectMake(0, 0, 200, 200) andDelegate:self withSections:8];
    wheel.center = CGPointMake(160, 240);
    [self.view addSubview:wheel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) wheelDidChangeValue:(NSString *)newValue {
    self.sectorLabel.text = newValue;
}

@end
