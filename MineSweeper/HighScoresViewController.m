//
//  HighScoresViewController.m
//  MineSweeper
//
//  Created by Eric Honan on 7/9/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import "HighScoresViewController.h"
#import "AFNetworking.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addHighScore:) name:@"HIGHSCORE" object:nil];
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

-(void)addHighScore:(NSNotification *)notification
{
    NSLog(@"notification: %@", [notification object]);
    
    NSString *username = @"Anonymous";
    
    //connect to database and add time here
    
    //hardcode username to begin with
    
    NSURL *baseurl = [NSURL URLWithString:@"http://fair-jigsaw-266.appspot.com"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseurl];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            username, @"username",
                            [notification object], @"time",
                            nil];
    
    NSLog(@"params: %@", params);
    
//    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/" parameters:params];
    
//    [operation start];
//    [operation waitUntilFinished];

}


@end
