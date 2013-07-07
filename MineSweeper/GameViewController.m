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

@interface GameViewController ()

@end

@implementation GameViewController

@synthesize timer, currentTime, score, timerDisplay, scoreDisplay, allCellRows, numberOfBombs;

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
    numberOfBombs = 6;
    
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
}

- (void)cellTapped: (UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"Cell Tapped");
    //[sender checkCell];
    Cell *cell = (Cell *)gestureRecognizer.view;
    [cell checkCell];
    
    if(cell.bomb)
    {
        NSLog(@"cell is a bomb");
        //end game
    }
    else
    {
        int bombCount = [self countNeighboringBombs:cell];
        cell.neighborBombCount.text = [NSString stringWithFormat:@"%i", [self countNeighboringBombs:cell]];
        NSLog(@"neighbor bomb count = %i", bombCount);
    }
}

- (int)countNeighboringBombs: (Cell*)cell
{
    NSLog(@"checking neighbors for bombs");
    int bombNumber = 0;
    //search for neighboring bombs
    
    //check cells above
    NSMutableDictionary *neighborRange = [self getRange: cell];
    
    // loop through rows in range
    for (int i = [[neighborRange objectForKey:@"top"] integerValue];
         i <= [[neighborRange objectForKey:@"bottom"] integerValue];
         i++) {
        NSMutableArray *currentRow = [allCellRows objectAtIndex:i];
        
        //loop through columns in row[i]
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

@end
