//
//  GameFieldViewController.m
//  MineSweeper
//
//  Created by Eric Honan on 7/2/13.
//  Copyright (c) 2013 Eric Honan. All rights reserved.
//

#import "GameViewController.h"
#import "Cell.h"
#import <QuartzCore/QuartzCore.h> //added for cell debugging (layer/border color)
#include <stdlib.h>

@interface GameViewController ()

@end

@implementation GameViewController

@synthesize timer, currentTime, score, timerDisplay, scoreDisplay, allCellRows, numberOfBombs, safeCellCount;

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
    [self newGameWithDifficulty: @"MEDIUM"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) newGameWithDifficulty: (NSString *)difficulty
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

- (void)buildGameBoard
{
    allCellRows = [[NSMutableArray alloc] init];
    
    // create 4x4 grid here
    NSMutableArray *currentRow = [[NSMutableArray alloc] init];
    
    UIView *gameBoard = [[UIView alloc] init];
    [self.view addSubview:gameBoard];
    
    for(int i=0; i < 16; ++i) //replace 16 with constant
    {
        //Create Cell
        Cell *cell = [[Cell alloc] init];        
        cell.frame = CGRectMake(0, 0, 30, 30);
        
        CGRect r = [cell frame];
        r.origin.x = [currentRow count] * (r.size.width + 1);
        r.origin.y = [allCellRows count] * (r.size.height + 1);
        [cell setFrame: r];
        
        [currentRow addObject:cell];
        
        if(i < numberOfBombs) //randomize this
        {
            //set current cell to bomb
            cell.bomb = true;
        }

        cell.addressX = i % 4; // or i % sqrt numCells
        cell.addressY = [allCellRows count];
                
        [gameBoard addSubview: cell];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [cell addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellHeld:)];
        [cell addGestureRecognizer:hold];

        if ([currentRow count] == 4)
        {
            [allCellRows addObject:currentRow];
            currentRow = NULL;
            currentRow = [[NSMutableArray alloc] init];
        }
    }
    
    gameBoard.frame = CGRectMake(100.0f, 175.0f, 123.0f, 123.0f); //make this dynamic based on board size
    //set gameboard background or border here
    [gameBoard.layer setBackgroundColor: [UIColor redColor].CGColor];
    
    [self addBombs:allCellRows];
}

- (void)addBombs:(NSMutableArray *)allRows
{
    //NSMutableArray *cellsWithBombs = [[NSMutableArray alloc] init];
    NSMutableArray *allCells = [[NSMutableArray alloc] init];

    //loop over each row in allRows
    for (int i = 0; i < [allRows count]; i++)
    {
        //loop over each cell in current row
        for (int j = 0; j < [[allRows objectAtIndex:i] count]; j++) {
            Cell *currentCell = [[allRows objectAtIndex:i] objectAtIndex:j];
            [allCells addObject:currentCell];
        }
    }
    
    numberOfBombs = 3;
    for (int i = numberOfBombs; i > 0; i--)
    {
        //get random int
        int r = arc4random() % [allCells count];
        NSLog(@"r = %i", r);
        Cell *bombCell = [allCells objectAtIndex: r];
        bombCell.bomb = true;
        [allCells removeObjectAtIndex:r]; //remove this cell so that it doesn't get added again
    }

    //add contents of allCellsArray to new temp array
    
    //randomly select cells from array and add bombs
}

- (void)cellTapped: (UIGestureRecognizer *)gestureRecognizer
{
    Cell *cell = (Cell *)gestureRecognizer.view;
    
    if(cell.flagged)
    {
        //unflag cell
        [cell flagCell];
    }
    else
    {
        [cell checkCell];

        if(cell.bomb)
        {
            NSLog(@"cell is a bomb");
            // when game is lost, display alert
            
            //create alert with 2 options (new game, return to home screen)
            UIAlertView *gameOverAlert = [[UIAlertView alloc] initWithTitle:@"GAME OVER!" message:@"You tapped a bomb" delegate:self cancelButtonTitle:@"Back To Menu" otherButtonTitles:@"Play Again!", nil];
            [gameOverAlert show];
        }
        else //cell is not a bomb
        {
            int bombCount = [self countNeighboringBombs:cell];
            cell.neighborBombCount.text = [NSString stringWithFormat:@"%i", bombCount];
            safeCellCount++;
        }
    }
    
    //This checks to see if only bombs are remaining (in which case the game is won)
    if(safeCellCount == (16 - numberOfBombs))
    {
        // when game is won, display high scores
        NSLog(@"pushing highscores view");
        [self performSegueWithIdentifier:@"highScoresSegue" sender:self];
        
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // back to menu button clicked
        NSLog(@"menu clicked");
    }
    else if (buttonIndex == 1)
    {
        NSLog(@"new game");
        [timer invalidate];
        [self buildGameBoard];
        [self newGameWithDifficulty:@"MEDIUM"];
        // play again button clicked
    }
}



- (void)cellHeld: (UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"cell held - flag it");
        Cell *cell = (Cell *)gestureRecognizer.view;
        [cell flagCell];
    }
}

- (int)countNeighboringBombs: (Cell*)cell
{
    int bombNumber = 0;
    
    //check cells above
    NSMutableDictionary *neighborRange = [self getRange: cell];
    
    // loop through rows in range
    for (int i = [[neighborRange objectForKey:@"top"] integerValue];
         i <= [[neighborRange objectForKey:@"bottom"] integerValue];
         i++) {
        NSMutableArray *currentRow = [allCellRows objectAtIndex:i];
        
        //loop through cells in column (row[i])
        for (int j = [[neighborRange objectForKey:@"left"] integerValue];
             j <= [[neighborRange objectForKey:@"right"] integerValue];
             j++) {
            NSLog(@"checking cell at row:%i, col:%i", i, j);
            Cell *currentCell = ((Cell *)[currentRow objectAtIndex: j]);
            if (currentCell.bomb) {
                NSLog(@"Bomb found!");
                bombNumber++;
            }
        }
    }    
    return bombNumber;
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
//        NSLog(@"cell is not edge (left/right). range is %i - %i", [[cellRange objectForKey:@"left"] integerValue], [[cellRange objectForKey:@"right"]integerValue]);
    }
    else if(cell.addressX == 0) // if on left edge
    {
        [cellRange setObject:[NSNumber numberWithInt: 0] forKey:@"left"];
        [cellRange setObject: [NSNumber numberWithInt: cell.addressX + 1] forKey:@"right"];
//        NSLog(@"cell is on left edge. range is %i - %i", [[cellRange objectForKey:@"left"] integerValue], [[cellRange objectForKey:@"right"]integerValue]);
    }
    else // if on right edge
    {
        [cellRange setObject: [NSNumber numberWithInt: cell.addressX - 1] forKey:@"left"];
        [cellRange setObject: [NSNumber numberWithInt:boardWidth] forKey:@"right"];
//        NSLog(@"row is on right edge. range is %i - %i", [[cellRange objectForKey:@"left"] integerValue], [[cellRange objectForKey:@"right"]integerValue]);
    }
    
    // set top and bottom edges if middle of board
    if (cell.addressY != 0 && cell.addressY != boardHeight)
    {
        [cellRange setObject: [NSNumber numberWithInt: cell.addressY -1] forKey:@"top"];
        [cellRange setObject: [NSNumber numberWithInt: cell.addressY + 1] forKey:@"bottom"];
//        NSLog(@"cell is not edge (top/bottom). range is %i - %i", [[cellRange objectForKey:@"top"] integerValue], [[cellRange objectForKey:@"bottom"] integerValue]);
    }
    else if(cell.addressY == 0) // if top
    {
        [cellRange setObject: [NSNumber numberWithInt: 0] forKey:@"top"];
        [cellRange setObject: [NSNumber numberWithInt:cell.addressY + 1] forKey:@"bottom"];
//        NSLog(@"cell is in top row. range is %i - %i", [[cellRange objectForKey:@"top"] integerValue], [[cellRange objectForKey:@"bottom"] integerValue]);
    }
    else // if bottom
    {
        [cellRange setObject: [NSNumber numberWithInt: cell.addressY - 1] forKey:@"top"];
        [cellRange setObject: [NSNumber numberWithInt: boardHeight] forKey:@"bottom"];
//        NSLog(@"cell is in bottom row. range is %i - %i", [[cellRange objectForKey:@"top"] integerValue], [[cellRange objectForKey:@"bottom"] integerValue]);
    }

    return cellRange;
}

- (void) timerTick
{
    currentTime++;
    timerDisplay.text = [NSString stringWithFormat:@"time: %i", currentTime];
}

- (void) gameOver
{
    NSLog(@"Game Over");
}

- (IBAction)backButton:(id)sender {
    //reset all existing vars
    [timer invalidate];
    NSLog(@"dismissing view controller");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
