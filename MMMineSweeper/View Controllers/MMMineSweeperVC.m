//
//  MMMineSweeperVC.m
//  MMMineSweeper
//
//  Created by Timothy Bellay on 10/11/15.
//  Copyright © 2015 Timothy Bellay. All rights reserved.
//

#import "MMMineSweeperVC.h"
#import "MMMineSweeperGrid.h"
#import "MMMineSweeperTile.h"

static float kTileWidth = 44.0f;
static float kTileHeight = 44.0f;
static float kLabelOffset = 2.0f;
static NSString *kMineLabelText = @"✹";
static NSString *kFlagLabelText = @"⚑";
static NSString *kGameStatusPlayText = @"PLAY!";
static NSString *kGameStatusGameOverText = @"GAME OVER!";
static NSString *kGAmeStatusVictoryText = @"VICTORY!";

typedef enum : NSUInteger {
	kGameStatusPlay,
	kGameStatusGameOver,
	kGameStatusVictory,
} MMMineSweeperGameStatus;

@interface MMMineSweeperVC () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *gridScrollView;
@property (strong, nonatomic) UIView *gridView;
@property (strong, nonatomic) MMMineSweeperGrid *grid;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *gridInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *mineInfoLabel;
@property (assign, nonatomic) MMMineSweeperGameStatus gameStatus;
@end

@implementation MMMineSweeperVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupBoard];
}

- (void)setupBoard {
	self.view.backgroundColor = [UIColor lightGrayColor];
	self.grid = [[MMMineSweeperGrid alloc] init8x8GridWith10mines];
	self.gridScrollView.delegate = self;
	self.gridScrollView.backgroundColor = [UIColor lightGrayColor];
	UIView *parentView = [self.gridScrollView superview];
	self.gridScrollView.contentSize = CGSizeMake(parentView.frame.size.width * 1.25f, parentView.frame.size.height * 1.25f);
	self.gridScrollView.contentOffset = CGPointMake(0.0f, 0.0f);
	self.gridView = [[UIView alloc] initWithFrame:self.gridScrollView.frame];
	self.gridScrollView.clipsToBounds = YES;
	[self.gridScrollView addSubview:self.gridView];
	
	self.gameStatus = kGameStatusPlay;
	[self setupGestureRecognizers];
	[self redrawBoard];
}

- (void)redrawBoard {
	for (UIView *view in [self.gridView subviews]) {
		[view removeFromSuperview];
	}
	[self drawGrid];
	[self addGridLabels];
	[self redrawStatusLabels];
}

- (void)redrawStatusLabels {
	NSString *rowsString = [NSString stringWithFormat:@"%li", (long)self.grid.size.rows];
	NSString *colsString = [NSString stringWithFormat:@"%li", (long)self.grid.size.cols];
	NSArray *gridInfoTextArray = [NSArray arrayWithObjects:rowsString, colsString, nil];
	self.gridInfoLabel.text = [@"grid:" stringByAppendingString:[gridInfoTextArray componentsJoinedByString:@"x"]];
	self.mineInfoLabel.text = [@"mines:" stringByAppendingString:[NSString stringWithFormat:@"%li",(long)[self.grid getNumberOfMines]]];
	
	switch (self.gameStatus) {
		case kGameStatusPlay:
			self.statusInfoLabel.text = kGameStatusPlayText;
			self.statusInfoLabel.textColor = [UIColor cyanColor];
			break;
		case kGameStatusGameOver:
			self.statusInfoLabel.text = kGameStatusGameOverText;
			self.statusInfoLabel.textColor = [UIColor redColor];
			break;
		case kGameStatusVictory:
			self.statusInfoLabel.text = kGAmeStatusVictoryText;
			self.statusInfoLabel.textColor = [UIColor greenColor];
			break;
		default:
			break;
	}
}

- (void)drawGrid {
	
	// TODO: resize self.gridView and center when grid is not 8x8. TB.
	
	for (int row = 0; row < self.grid.size.rows; row++) {
		for (int col = 0; col < self.grid.size.cols; col++){
			CGRect rect = CGRectMake(col * kTileWidth, row * kTileHeight, kTileWidth, kTileHeight);
			UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
			CAShapeLayer *tileLayer = [[CAShapeLayer alloc] init];
			[tileLayer setPath:path.CGPath];
			tileLayer.strokeColor = [UIColor lightGrayColor].CGColor;
			tileLayer.fillColor = [UIColor darkGrayColor].CGColor;
			[self.gridView.layer addSublayer:tileLayer];
		}
	}
}

- (void)drawRectsForViewsIn:(UIView *)superView {
	for (UIView *view in superView.subviews) {
		CGRect frame = view.frame;
		UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
		CAShapeLayer *pathLayer = [[CAShapeLayer alloc] init];
		[pathLayer setPath:path.CGPath];
		pathLayer.strokeColor = [UIColor greenColor].CGColor;
		pathLayer.fillColor = [UIColor clearColor].CGColor;
		[superView.layer addSublayer:pathLayer];
	}
}

- (void)addGridLabels {
	for (int row = 0; row < self.grid.size.rows; row++) {
		for (int col = 0; col < self.grid.size.cols; col++){
			if ([self.grid isTileSelectedAtRow:row col:col]) {
				CGRect rect = CGRectMake(col * kTileWidth + kLabelOffset , row * kTileHeight + kLabelOffset, kTileWidth - 2 * kLabelOffset, kTileHeight - 2 * kLabelOffset);
				UILabel *label = [[UILabel alloc] initWithFrame:rect];
				if ([self.grid hasMineAtRow:row col:col]) {
					label.text = kMineLabelText;
					label.backgroundColor = [UIColor colorWithRed:1.0f green:0.25f blue:0.25f alpha:0.2f];
					label.textColor = [UIColor orangeColor];
				} else {
					label.text = [NSString stringWithFormat:@"%lu",[self.grid getMineCountForTileAtRow:row col:col]];
					label.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
					label.textColor = [UIColor whiteColor];
				}
				label.textAlignment = NSTextAlignmentCenter;
				[self.gridView addSubview:label];
			} else if ([self.grid isTileFlaggedAtRow:row col:col]){
				CGRect rect = CGRectMake(col * kTileWidth + kLabelOffset , row * kTileHeight + kLabelOffset, kTileWidth - 2 * kLabelOffset, kTileHeight - 2 * kLabelOffset);
				UILabel *label = [[UILabel alloc] initWithFrame:rect];
				label.text = kFlagLabelText;
				label.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
				label.textColor = [UIColor cyanColor];
				label.textAlignment = NSTextAlignmentCenter;
				[self.gridView addSubview:label];
			}
		}
	}
	
	
	if ([self.grid isGodModeOn]) {
		for (int row = 0; row < self.grid.size.rows; row++) {
			for (int col = 0; col < self.grid.size.cols; col++){
				CGRect rect = CGRectMake(col * kTileWidth + kLabelOffset , row * kTileHeight + kLabelOffset, kTileWidth - 2 * kLabelOffset, kTileHeight - 2 * kLabelOffset);
				UILabel *label = [[UILabel alloc] initWithFrame:rect];
				if ([self.grid hasMineAtRow:row col:col]) {
					label.text = kMineLabelText;
				}
				label.textAlignment = NSTextAlignmentCenter;
				label.textColor = [UIColor orangeColor];
				[self.gridView addSubview:label];
			}
		}
	}
}


#pragma mark - Gestures

- (void)setupGestureRecognizers {
	self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
	[self.gridView addGestureRecognizer:self.tapGestureRecognizer];
	[self.gridView addGestureRecognizer:self.longPressGestureRecognizer];
	self.longPressGestureRecognizer.minimumPressDuration = 0.5f;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapRecogniser {
	if (![self.grid isGameOver]) {
		CGPoint touchLocation = [tapRecogniser locationInView:self.gridView];
		int row = touchLocation.y / kTileWidth ;
		int col = touchLocation.x / kTileHeight;
		if (![self.grid isTileSelectedAtRow:row col:col]) {
			[self.grid didTapTileAtRow:row col:col];
			[self redrawBoard];
		}
	}
	
	if ([self.grid isGameOver]) { // This is one "code smell" reason why I need to extract game state logic from MMMineSweeperGrid. TB.
		self.gameStatus = kGameStatusGameOver;
		[self redrawBoard];
	}
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressRecognizer {
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		if (![self.grid isGameOver]) {
			CGPoint touchLocation = [longPressRecognizer locationInView:self.gridView];
			int row = touchLocation.y / kTileWidth ;
			int col = touchLocation.x / kTileHeight;
			if (![self.grid isTileSelectedAtRow:row col:col]){
				[self.grid didLongPressTileAtRow:row col:col];
				[self redrawBoard];
			}
		}
	}
}

- (IBAction)didPressGodMode:(id)sender {
	[self.grid toggleGodMode];
	[self redrawBoard];
}

- (IBAction)didPressRedo:(id)sender {
	[self setupBoard];
}

- (IBAction)didPressValidate:(id)sender {
	if ([self.grid isGameValidated]) {
		self.gameStatus = kGameStatusVictory;
		[self redrawStatusLabels];
		NSLog(@"YOU WIN!");
	} else {
		self.gameStatus = kGameStatusGameOver;
		[self redrawBoard];
		NSLog(@"YOU LOST!");
	}
}

@end
