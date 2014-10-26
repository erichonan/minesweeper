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

@synthesize highscoresTextarea, nameEntryField, userScore;

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
    

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://fair-jigsaw-266.appspot.com"]];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    // not sure if this part is necessary
    // [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"/getScores" parameters:nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            
                                                                                            
                                                                                            NSArray *tenScores = [NSArray arrayWithArray:JSON];
                                                                                            
                                                                                            NSMutableString *scoresAsText = [[NSMutableString alloc] init];
                                                                                            
                                                                                            for(int i = 0; i < [tenScores count]; i++)
                                                                                            {
                                                                                                NSString *uname = [[tenScores objectAtIndex:i] objectForKey:@"playerName"];
                                                                                                int uscore = [[[tenScores objectAtIndex:i] objectForKey:@"score"] integerValue];
                                                                                                [scoresAsText appendString: [NSString stringWithFormat:@"%@ : %.2f \n", uname, (float)uscore / 100]];
                                                                                            }
                                                                                            
                                                                                            NSLog(@"scoresAsText = %@", scoresAsText);
                                                                                            highscoresTextarea.text = scoresAsText;
                                                                                            
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"FAILURE!");
                                                                                            NSLog(@"error message: %@", error);
                                                                                            NSLog(@"JSON = %@", JSON);
                                                                                        }];
    [operation start];
    [operation waitUntilFinished];
    
}

- (void)addHighScore
{
    NSLog(@"addHighScore called");
    
    //connect to database and add time here
    
    //hardcode username to begin with
    
    NSURL *baseurl = [NSURL URLWithString:@"http://fair-jigsaw-266.appspot.com"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseurl];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    */
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            nameEntryField.text, @"username",
                            [NSString stringWithFormat:@"%i", userScore], @"time",
                            nil];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/" parameters:params];
    //create an alert
    UIAlertView *highscoreFeedback = [[UIAlertView alloc] initWithTitle:@"highscore feedback" message:@"success!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            
                                                                                            NSDictionary *scoreResults = [NSDictionary dictionaryWithDictionary:params];
                                                                                            NSLog(@"gradeResults from GradeViewController: %@", scoreResults);
                                                                                            
                                                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            highscoreFeedback.message = [NSString stringWithFormat: @"%@", error];
                                                                                            [highscoreFeedback show];
                                                                                            NSLog(@"failure");
                                                                                            NSLog(@"error message: %@", error);
                                                                                            NSLog(@"JSON = %@", JSON);
                                                                                        }];
    
    [operation start];
    [operation waitUntilFinished];

}


@end
