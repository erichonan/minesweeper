//
//  HighScoresViewController.h
//  MineSweeper
//
//  Created by Eric Honan on 7/9/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoresViewController : UIViewController
- (IBAction)playAgain:(id)sender;
- (IBAction)backToMenu:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *highscoresText;

@end
