//
//  HighScoresViewController.m
//  MineSweeper
//
//  Created by Eric Honan on 7/9/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import "HighScoresViewController.h"

@interface HighScoresViewController ()

@end

@implementation HighScoresViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //request top 20 highscores
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playAgain:(id)sender {
    NSLog(@"Play Again Tapped");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backToMenu:(id)sender {
    NSLog(@"back to menu");
    //[self dismissViewControllerAnimated:YES completion:nil];
    NSNotification *notification =[NSNotification notificationWithName:@"RETURN_TO_MENU" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification: notification];
}
@end
