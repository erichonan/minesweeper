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
            bombView,
            coveredStateView,
            flagView,
            flagged,
            checked,
            neighborBombCount,
            bomb,
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
    neighborBombCount.text = @"?";
    [self addSubview:neighborBombCount];

    // covered zone
    coveredStateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [coveredStateView setBackgroundColor:[UIColor grayColor]];
    [self addSubview:coveredStateView];
    
    
    flagView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 10.0f, 10.0f)];
    [flagView setBackgroundColor:[UIColor blueColor]];
}

- (BOOL)checkCell
{
    NSLog(@"checking cell");
    if (!checked) {
        checked = TRUE;
    }
    
    if (bomb) {
        [self addSubview:bombView];
        [neighborBombCount removeFromSuperview];
    }
    
    if (neighborBombCount > 0 && !bomb)
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

@end
