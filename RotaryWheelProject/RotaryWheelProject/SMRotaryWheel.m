//
//  SMRotaryWheel.m
//  RotaryWheelProject
//
//  Created by Tim on 12/30/12.
//  Copyright (c) 2012 broderboy. All rights reserved.
//

#import "SMRotaryWheel.h"
#import <QuartzCore/QuartzCore.h>

@interface SMRotaryWheel()
- (void)drawWheel;
- (float) calculateDistanceFromCenter:(CGPoint)point;
- (void) buildSectorsEven;
- (void) buildSectorsOdd;
- (UIImageView *) getSectorByValue:(int)value;
@end

static float deltaAngle;
static float minAlphavalue = 0.6;
static float maxAlphavalue = 1.0;

@implementation SMRotaryWheel

@synthesize delegate, container, numberOfSections, startTransform, sectors, currentSector;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)numSections
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfSections = numSections;
        self.delegate = del;
            NSLog(@"InitWithFrame");
        [self drawWheel];
        self.currentSector = 0;
        //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(rotate) userInfo:nil repeats:YES];
    }
    return self;
}

- (void) drawWheel
{
    NSLog(@"drawWheel with %i", numberOfSections);
    container = [[UIView alloc] initWithFrame:self.frame];
    CGFloat angleSize = 2 * M_PI / numberOfSections;
    
    for (int i=0; i<numberOfSections; i++) {
        //Label Version
        /*
        UILabel *im = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        im.backgroundColor = [UIColor redColor];
        im.text = [NSString stringWithFormat:@"%i", i];
        im.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        
        im.layer.position = CGPointMake(container.bounds.size.width / 2.0, container.bounds.size.height / 2.0);
        im.transform = CGAffineTransformMakeRotation(angleSize * i);
        im.tag = i;
         */
        
        UIImageView *im = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"segment.png"]];
        im.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        im.layer.position = CGPointMake(container.bounds.size.width / 2.0, container.bounds.size.height / 2.0);
        im.transform = CGAffineTransformMakeRotation(angleSize * i);
        im.tag = i;
        im.alpha = minAlphavalue;

        if (i == 0) {
            im.alpha = maxAlphavalue;
        }
        
        UIImageView *sectorImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 40, 40)];
        sectorImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon%i.png", i]];
        [im addSubview:sectorImage];
        
        [container addSubview:im];
    }
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
    bg.image = [UIImage imageNamed:@"centerButton.png"];
    [self addSubview:bg];
    
    UIImageView *mask = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    mask.image = [UIImage imageNamed:@"centerButton.png"];
    mask.center = self.center;
    mask.center = CGPointMake(mask.center.x, mask.center.y);
    [self addSubview:mask];
    
    sectors = [NSMutableArray arrayWithCapacity:numberOfSections];
    if (numberOfSections % 2 == 0) {
        [self buildSectorsEven];
    }
    else {
        NSLog(@"should build odd");
        [self buildSectorsOdd];
    }
    
    container.userInteractionEnabled = NO;
    [self addSubview:container];
    [self.delegate wheelDidChangeValue:[NSString stringWithFormat:@"value is %i", self.currentSector]];
}

- (void) rotate
{
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -0.78);
    container.transform = t;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    // get the touch position
    CGPoint touchPoint = [touch locationInView:self];
    
    //dn't want to track too close to the center
    float dist = [self calculateDistanceFromCenter:touchPoint];
    if (dist < 40 || dist > 100) {
        NSLog(@"ignoring tab at (%f,%f)", touchPoint.x, touchPoint.y);
        return NO;
    }
    
    //calculate distance from the center
    float dx = touchPoint.x - container.center.x;
    float dy = touchPoint.y - container.center.y;
    
    //calculate angle
    deltaAngle = atan2f(dx, dy);
    
    UIImageView *im = [self getSectorByValue:currentSector];
    im.alpha = minAlphavalue;
    
    //save transform
    startTransform = container.transform;
    return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    NSLog(@"rad is %f", radians);
    
    // get the touch position
    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self calculateDistanceFromCenter:touchPoint];
    if (dist < 40 || dist > 100) {
        //NSLog(@"ignoring tab at (%f,%f)", touchPoint.x, touchPoint.y);
        //return NO;
    }
    
    //calculate distance from the center
    float dx = touchPoint.x - container.center.x;
    float dy = touchPoint.y - container.center.y;
    
    float ang = atan2f(dx, dy);
    float andlgeDifference = deltaAngle - ang;
    container.transform = CGAffineTransformRotate(startTransform, andlgeDifference);
    return YES;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //curr radian
    CGFloat radians = atan2f(container.transform.b, container.transform.a);
    NSLog(@"rad is %f", radians);

    //init new val;
    CGFloat newVal = 0.0;
    
    //iterate through all sectors;
    for (SMSector *s in sectors) {
        //see if curr sector contains the curr radian val
        if (s.minValue > 0 && s.maxValue < 0) {
            if (s.maxValue > radians || s.minValue < radians) {
                if (radians > 0) {
                    newVal = radians - M_PI;
                }
                else {
                    newVal = M_PI + radians;
                }
                currentSector = s.sector;
            }
        }
        else if (radians > s.minValue && radians < s.maxValue) {
            newVal = radians - s.midValue;
            currentSector = s.sector;
        }
        [self.delegate wheelDidChangeValue:[NSString stringWithFormat:@"value is %i", self.currentSector]];
    }
    
    //animate final rotation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform t = CGAffineTransformRotate(container.transform, -newVal);
    container.transform = t;
    [UIView commitAnimations];
    
    UIImageView *im = [self getSectorByValue:currentSector];
    im.alpha = maxAlphavalue;
}

- (float) calculateDistanceFromCenter:(CGPoint)point
{
    CGPoint center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}

- (void) buildSectorsOdd
{
    NSLog(@"building odd");
    //sector length
    CGFloat fanWidth = M_PI * 2 / numberOfSections;
    
    //initial midpoint
    CGFloat mid = 0;
    
    //loop and create sectors
    for (int i=0; i<numberOfSections; i++) {
        SMSector *sector = [[SMSector alloc] init];
        
        sector.midValue = mid;
        sector.minValue = mid - (fanWidth/2);
        sector.maxValue = mid + (fanWidth/2);
        sector.sector = i;
        mid -= fanWidth;
        
        if (sector.minValue < - M_PI) {
            mid = -mid;
            mid -=fanWidth;
        }
        
        [sectors addObject:sector];
        NSLog(@"cl is %@", sector);
    }
}

- (void) buildSectorsEven
{
    NSLog(@"building even");
    //sector length
    CGFloat fanWidth = M_PI * 2 / numberOfSections;
    
    //initial midpoint
    CGFloat mid = 0;
    
    //loop and create sectors
    for (int i=0; i<numberOfSections; i++) {
        SMSector *sector = [[SMSector alloc] init];
        sector.midValue = mid;
        sector.minValue = mid - (fanWidth/2);
        sector.maxValue = mid + (fanWidth/2);
        sector.sector = i;
        
        if (sector.maxValue-fanWidth < - M_PI) {
            mid = M_PI;
            sector.midValue = mid;
            sector.minValue = fabs(sector.maxValue);
        }
        
        mid -=fanWidth;
        
        [sectors addObject:sector];
        NSLog(@"cl is %@", sector);
    }
}

- (UIImageView *) getSectorByValue:(int)value
{
    UIImageView *res;
    NSArray *views = [container subviews];
    for (UIImageView *im in views) {
        if (im.tag == value) {
            res = im;
            
        }
    }
    return res;
}



@end
