//
//  Cell.h
//  MineSweeper
//
//  Created by Eric Honan on 7/2/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UIControl

@property UIView *defaultStateView, *bombView, *coveredStateView, *flagView;
@property UILabel *neighborBombCount;
@property BOOL flagged, checked, bomb;
@property int addressX, addressY;

-(void) placeBomb;
- (void)revealCell;
- (BOOL)checkCell;
- (BOOL)flagCell;

@end
