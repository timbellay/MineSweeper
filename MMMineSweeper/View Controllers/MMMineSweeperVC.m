//
//  MMMineSweeperVC.m
//  MMMineSweeper
//
//  Created by Timothy Bellay on 10/11/15.
//  Copyright © 2015 Timothy Bellay. All rights reserved.
//

#import "MMMineSweeperVC.h"
#import "MMMineSweeperGrid.h"

@interface MMMineSweeperVC ()
@property (weak, nonatomic) IBOutlet UIView *gridView;
@end

@implementation MMMineSweeperVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupBoard];
	
	
	
//	NSDictionary *subscript = [MMMineSweeperGrid convertIndex:36 fromSize:grid.size];
//	NSInteger ind = [MMMineSweeperGrid convertSubscript:subscript fromSize:grid.size];
	
    // Do any additional setup after loading the view.
}

- (void)setupBoard {
	MMMineSweeperGrid *grid = [[MMMineSweeperGrid alloc] init8x8GridWith10mines];
	
	
	
	[self redrawBoard];
}

- (void)redrawBoard {
	
}

- (void)setupGestureRecognizers {
	
}

@end
