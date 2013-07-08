//
//  GameFieldViewController.h
//  MineSweeper
//
//  Created by Eric Honan on 7/2/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *timerDisplay;
@property (weak, nonatomic) IBOutlet UILabel *scoreDisplay;
- (IBAction)backButton:(id)sender;

@property NSTimer *timer;
@property int score, currentTime, numberOfBombs;
@property NSMutableArray *allCellRows;

- (void)cellTapped: (id)sender;
- (void) newGameWithDifficulty: (NSString *)difficulty;
- (void) buildGameBoard;
- (void) gameOver;

@end