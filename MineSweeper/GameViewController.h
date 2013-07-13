//
//  GameFieldViewController.h
//  MineSweeper
//
//  Created by Eric Honan on 7/2/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cell.h"

@interface GameViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerDisplay;
- (IBAction)backButton:(id)sender;
- (IBAction)winGameButton:(id)sender;

@property NSTimer *timer;
@property int currentTime, numberOfBombs, safeCellCount;
@property NSMutableArray *allCellRows, *allCells;


- (NSMutableDictionary *) getRange:(Cell *)cell;
- (void) cellTapped: (id)sender;
- (void) newGameWithDifficulty: (NSString *)difficulty;
- (void) buildGameBoard;
- (void) resetGame;
@end