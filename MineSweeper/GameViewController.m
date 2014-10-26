//
//  GameFieldViewController.m
//  MineSweeper
//
//  Created by Eric Honan on 7/2/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h> //added for cell debugging (layer/border color)
#include <stdlib.h>

@interface GameViewController ()

@end

@implementation GameViewController

@synthesize timer, currentTime, timerDisplay, allCellRows, allCells, numberOfBombs, safeCellCount;

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
    NSLog(@"view did load");
    [super viewDidLoad];
    [self buildGameBoard];
    [self newGameWithDifficulty: @"MEDIUM"]; //TO DO: Add difficulty functionality
    
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(backToMenu) name:@"RETURN_TO_MENU" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetGame) name:@"RESET_GAME" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) newGameWithDifficulty: (NSString *)difficulty
{
    timer = [NSTimer scheduledTimerWithTimeInterval:.01f target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

- (void)buildGameBoard
{
    allCellRows = [[NSMutableArray alloc] init];
    
    // create 4x4 grid here
    NSMutableArray *currentRow = [[NSMutableArray alloc] init];
    allCells = [[NSMutableArray alloc] init];
    
    UIView *gameBoard = [[UIView alloc] init];
    [self.view addSubview:gameBoard];
    
    for(int i=0; i < 64; ++i) //replace 16 with constant
    {
        //Create Cell
        Cell *cell = [[Cell alloc] init];        
        cell.frame = CGRectMake(0, 0, 30, 30);
        
        CGRect r = [cell frame];
        r.origin.x = [currentRow count] * (r.size.width + 1);
        r.origin.y = [allCellRows count] * (r.size.height + 1);
        [cell setFrame: r];
        
        [currentRow addObject:cell];
        [allCells addObject:cell];

        cell.addressX = i % 8; // or i % sqrt numCells
        cell.addressY = [allCellRows count];
                
        [gameBoard addSubview: cell];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [cell addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellHeld:)];
        [cell addGestureRecognizer:hold];

        if ([currentRow count] == 8)
        {
            [allCellRows addObject:currentRow];
            currentRow = NULL;
            currentRow = [[NSMutableArray alloc] init];
        }
    }
    
    float width = 8 * 30 + 7;
    float height = width;
    gameBoard.frame = CGRectMake(40.0f, 110.0f, width, height); //make this dynamic based on board size
    //set gameboard background or border here
    [gameBoard.layer setBackgroundColor: [UIColor blackColor].CGColor];
    
    [self addBombs:allCellRows];
}

- (void)addBombs:(NSMutableArray *)allRows
{
    NSMutableArray *bombSelectArray = [allCells mutableCopy];
    numberOfBombs = 10;
    for (int i = numberOfBombs; i > 0; i--)
    {
        //get random int
        int r = arc4random() % [bombSelectArray count];
        Cell *bombCell = [allCells objectAtIndex: r];
        bombCell.bomb = true;
        [bombSelectArray removeObjectAtIndex:r]; //remove this cell so that it doesn't get added again
    }
}

- (void)cellTapped: (UIGestureRecognizer *)gestureRecognizer
{
    Cell *cell = (Cell *)gestureRecognizer.view;
    
    if(cell.flagged)
    {
        [cell flagCell]; //unflag cell
    }
    else
    {
        [cell checkCell];

        if(cell.bomb)
        {
            // when game is lost, display alert
            
            //create alert with 2 options (new game, return to home screen)
            UIAlertView *gameOverAlert = [[UIAlertView alloc] initWithTitle:@"GAME OVER!" message:@"You tapped a bomb" delegate:self cancelButtonTitle:@"Back To Menu" otherButtonTitles:@"Play Again!", nil];
            [gameOverAlert show];
            //stop timer here
            [timer invalidate];
        }
        else //cell is not a bomb
        {
            int bombCount = [self countNeighboringBombs:cell];
            cell.neighborBombCount.text = [NSString stringWithFormat:@"%i", bombCount];
            safeCellCount++;
        }
    }
    
    if(safeCellCount == (64 - numberOfBombs))     //This checks to see if only bombs are remaining (in which case the game is won)
    {
        [self winGame];
    }
}

- (void) winGame
{
    NSLog(@"win game called");
    [self performSegueWithIdentifier:@"highScoresSegue" sender:self]; // display high scores
    
    //now pass along a notification
    NSNotification *newHighScore = [NSNotification notificationWithName:@"HIGHSCORE" object: [NSNumber numberWithInt:currentTime]];
    [[NSNotificationCenter defaultCenter] postNotification:newHighScore];
    
    [self resetGame];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) // back to menu
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (buttonIndex == 1) // play again
    {
        [self resetGame];
    }
}

- (void)cellHeld: (UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        Cell *cell = (Cell *)gestureRecognizer.view;
        [cell flagCell];
    }
}

- (int)countNeighboringBombs: (Cell*)cell
{
    int bombNumber = 0;
    
    //check cells above
    NSMutableDictionary *neighborRange = [self getRange: cell];
    NSMutableArray *neighborCells = [[NSMutableArray alloc] init];
    
    // loop through rows in range
    for (int i = [[neighborRange objectForKey:@"top"] integerValue];
         i <= [[neighborRange objectForKey:@"bottom"] integerValue];
         i++) {
        NSMutableArray *currentRow = [allCellRows objectAtIndex:i];
        
        //loop through cells in column (row[i])
        for (int j = [[neighborRange objectForKey:@"left"] integerValue];
             j <= [[neighborRange objectForKey:@"right"] integerValue];
             j++) {

            Cell *currentCell = ((Cell *)[currentRow objectAtIndex: j]);
            
            if(currentCell == cell)
            {
                NSLog(@"This is the clicked cell address: x=%i - y=%i", currentCell.addressX, currentCell.addressY);
                [neighborCells addObject:currentCell];
            }
            
            if (currentCell.bomb) {
                NSLog(@"Bomb found!");
                bombNumber++;
            }
        }
    }
    
    // The problem here is that the cell with 0 bombs gets checked again and again
    /*
    if(bombNumber == 0)
    {
        NSLog(@"No neighboring bombs - need to check all neighbors");
        for (int k = 0; k < [neighborCells count]; k++) {
            NSLog(@"checking neighboring cell (recursive): k = %i", k);
            Cell *cell = [neighborCells objectAtIndex:k];
            [cell checkCell];
            [self countNeighboringBombs:cell];
        }
    }*/
    
    return bombNumber;
}

- (IBAction)winGameButton:(id)sender {
    //[self performSegueWithIdentifier:@"highScoresSegue" sender:self]; // display high scores
    //now pass along a notification
    [self winGame];
}

- (NSMutableDictionary *) getRange:(Cell *)cell
{
    int boardWidth = [[allCellRows objectAtIndex:0] count] - 1;
    int boardHeight = [allCellRows count] - 1;
    
    //check cells above
    NSMutableDictionary *cellRange = [[NSMutableDictionary alloc] init];
    
    // set left and right edges if middle of board
    if (cell.addressX != 0 && cell.addressX != boardWidth) {
        [cellRange setObject:[NSNumber numberWithInt: cell.addressX - 1] forKey:@"left"];
        [cellRange setObject: [NSNumber numberWithInt: cell.addressX + 1] forKey:@"right"];
    }
    else if(cell.addressX == 0) // if on left edge
    {
        [cellRange setObject:[NSNumber numberWithInt: 0] forKey:@"left"];
        [cellRange setObject: [NSNumber numberWithInt: cell.addressX + 1] forKey:@"right"];
    }
    else // if on right edge
    {
        [cellRange setObject: [NSNumber numberWithInt: cell.addressX - 1] forKey:@"left"];
        [cellRange setObject: [NSNumber numberWithInt:boardWidth] forKey:@"right"];
    }
    
    // set top and bottom edges if middle of board
    if (cell.addressY != 0 && cell.addressY != boardHeight)
    {
        [cellRange setObject: [NSNumber numberWithInt: cell.addressY -1] forKey:@"top"];
        [cellRange setObject: [NSNumber numberWithInt: cell.addressY + 1] forKey:@"bottom"];
    }
    else if(cell.addressY == 0) // if top
    {
        [cellRange setObject: [NSNumber numberWithInt: 0] forKey:@"top"];
        [cellRange setObject: [NSNumber numberWithInt:cell.addressY + 1] forKey:@"bottom"];
    }
    else // if bottom
    {
        [cellRange setObject: [NSNumber numberWithInt: cell.addressY - 1] forKey:@"top"];
        [cellRange setObject: [NSNumber numberWithInt: boardHeight] forKey:@"bottom"];
    }

    return cellRange;
}

- (void) timerTick
{
    currentTime++;
    timerDisplay.text = [NSString stringWithFormat:@"%.2f", (float)currentTime / 100];
}

- (void) resetGame
{
    NSLog(@"reset game");
    [allCellRows removeAllObjects];
    
    for(int i = 0; i < [allCells count]; i++)
    {
        Cell *cell = [allCells objectAtIndex:i];
        [cell removeFromSuperview];
        cell = nil;
    }
    
    [timer invalidate];
    timerDisplay.text = @"time: 0";
    currentTime = 0;
    numberOfBombs = 0;
    safeCellCount = 0;

    [self buildGameBoard];
    [self newGameWithDifficulty:@"MEDIUM"];
}

- (IBAction)backButton:(id)sender {
    [self backToMenu];
}

- (void)backToMenu
{
    NSLog(@"going back to menu");
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self removeFromParentViewController];
}

@end
