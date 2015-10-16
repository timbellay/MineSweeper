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

#define kTileWidth 44.0f
#define kTileHeight 44.0f
#define kLabelOffset 2.0f
#define kMineLabelText @"✹"
#define kFlagLabelText @"⚑"

@interface MMMineSweeperVC () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *gridView;
@property (strong, nonatomic) MMMineSweeperGrid *grid;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@end

@implementation MMMineSweeperVC

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupBoard];
}

- (void)setupBoard {
	self.grid = [[MMMineSweeperGrid alloc] init8x8GridWith10mines];
	[self setupGestureRecognizers];
	[self redrawBoard];
}

- (void)redrawBoard {
	for (UIView *view in [self.gridView subviews]) {
		[view removeFromSuperview];
	}
	[self drawGrid];
	[self addGridLabels];
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

- (void)addGridLabels {
	for (int row = 0; row < self.grid.size.rows; row++) {
		for (int col = 0; col < self.grid.size.cols; col++){
			if ([self.grid isTileSelectedAtRow:row col:col]) {
				CGRect rect = CGRectMake(col * kTileWidth + kLabelOffset , row * kTileHeight + kLabelOffset, kTileWidth - 2*kLabelOffset, kTileHeight - 2*kLabelOffset);
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
				CGRect rect = CGRectMake(col * kTileWidth + kLabelOffset , row * kTileHeight + kLabelOffset, kTileWidth - 2*kLabelOffset, kTileHeight - 2*kLabelOffset);
				UILabel *label = [[UILabel alloc] initWithFrame:rect];
				label.text = kFlagLabelText;
				label.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
				label.textColor = [UIColor whiteColor];
				label.textAlignment = NSTextAlignmentCenter;
				[self.gridView addSubview:label];
			}
		}
	}
	
	
	if ([self.grid isGodModeOn]) {
		for (int row = 0; row < self.grid.size.rows; row++) {
			for (int col = 0; col < self.grid.size.cols; col++){
				CGRect rect = CGRectMake(col * kTileWidth + kLabelOffset , row * kTileHeight + kLabelOffset, kTileWidth - 2*kLabelOffset, kTileHeight - 2*kLabelOffset);
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
	self.longPressGestureRecognizer.minimumPressDuration = 0.25f;
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
		NSLog(@"YOU WIN!");
	} else {
		[self redrawBoard];
		NSLog(@"YOU LOST!");
	}
}

@end
