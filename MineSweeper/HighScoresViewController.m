//
//  HighScoresViewController.m
//  MineSweeper
//
//  Created by Eric Honan on 7/9/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import "HighScoresViewController.h"
#import "GameViewController.h"
#import "AFNetworking.h"

@interface HighScoresViewController ()

@end

@implementation HighScoresViewController

@synthesize highscoresTextarea, nameEntryField, userScore, highscores;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameWon:) name:@"HIGHSCORE" object:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    highscores = [NSArray arrayWithArray:[defaults arrayForKey:@"highscores"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playAgain:(id)sender {
    // This needs to dispatch a notification to reset the game - it should not be reset before then
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RESET_GAME" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backToMenu:(id)sender {
    NSLog(@"back to menu");
    //[self dismissViewControllerAnimated:YES completion:nil];
    NSNotification *notification =[NSNotification notificationWithName:@"RETURN_TO_MENU" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification: notification];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textfield should return");
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)submitScore:(id)sender {
    [self addHighScore];
    [self displayHighScores];
}

- (void)gameWon:(NSNotification *) notification
{
    userScore = [[notification object] integerValue];
    [self displayHighScores];
}

- (void)displayHighScores
{
    
    NSLog(@"displayHighScores called");

    
}

- (void)addHighScore
{
    NSLog(@"addHighScore called");
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"some cell selected");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    cell.textLabel.text = [highscores objectAtIndex:indexPath.row];
    NSLog(@"%lu", (unsigned long)[highscores count]);
    NSLog(@"detail label text: %@", cell.textLabel.text);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


@end
