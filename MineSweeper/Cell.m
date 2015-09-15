//
//  Cell.m
//  MineSweeper
//
//  Created by Eric Honan on 7/2/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import "Cell.h"

@implementation Cell

@synthesize defaultStateView,
            coveredStateView,
            bomb,
            bombView,
            flagView,
            flagged,
            checked,
            neighborBombCount,
            addressX,
            addressY;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // uncovered zone
    defaultStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [defaultStateView setBackgroundColor:[UIColor orangeColor]];
    [self addSubview:defaultStateView];    
    
    // bomb
    bombView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 10.0f, 10.0f)];
    [bombView setBackgroundColor:[UIColor redColor]];
    
    // neighbor bomb count label
    neighborBombCount = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0f, 30.0f, 30.0f)];
    //neighborBombCount.text = @"?";
    [self addSubview:neighborBombCount];

    // covered zone
    coveredStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [coveredStateView setBackgroundColor:[UIColor grayColor]];
    [self addSubview:coveredStateView];
    
    
    flagView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 10.0f, 10.0f)];
    [flagView setBackgroundColor:[UIColor blueColor]];
}

-(void) updateNeighborCount: (int) threatCount  {
    neighborBombCount.text = [NSString stringWithFormat:@"%i", threatCount];
    //this doesn't make any sense. I need to review the measurements exactly to see what is happening here
    CGFloat centeredX = neighborBombCount.frame.size.width*0.25;
    CGFloat centeredY = neighborBombCount.frame.size.height*0.25;
    NSLog(@"centeredX: %f; centeredY: %f; width: %f; height: %f", centeredX, centeredY, neighborBombCount.frame.size.width, neighborBombCount.frame.size.height);
    neighborBombCount.frame = CGRectMake(centeredX, centeredY, neighborBombCount.frame.size.width, neighborBombCount.frame.size.height);
}

-(void) placeBomb   {
    self.bomb = true;
    //[self addSubview:bombView];
    //[neighborBombCount removeFromSuperview];
}

- (BOOL)checkCell
{
    NSLog(@"checking cell");
    if (!checked) {
        checked = TRUE;
    }
    
    if (bomb) {     //this should end the game.. right?
        [coveredStateView setAlpha:0.0];
    }
    
    if (neighborBombCount > 0 && !bomb) //why is this conditional not used?
    {
        //display bomb count
    }
    
    [coveredStateView removeFromSuperview];
    
    return checked;
}

- (BOOL)flagCell
{
    if(flagged)
    {
        flagged = FALSE;
        [flagView removeFromSuperview];
    }
    else
    {
        flagged = TRUE;
        [self addSubview:flagView];
    }
    return flagged;
}

- (void)revealCell
{
    [coveredStateView setAlpha:0.5];
}

@end
