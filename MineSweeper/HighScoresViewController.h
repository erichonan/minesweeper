//
//  HighScoresViewController.h
//  MineSweeper
//
//  Created by Eric Honan on 7/9/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoresViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
- (IBAction)playAgain:(id)sender;
- (IBAction)backToMenu:(id)sender;
- (IBAction)submitScore:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@property (weak, nonatomic) IBOutlet UITextView *highscoresTextarea;
@property (weak, nonatomic) IBOutlet UITextField *nameEntryField;
@property int userScore;
@property NSArray* highscores;
@end
