//
//  MMMineSweeperGrid.m
//  MMMineSweeper
//
//  Created by Timothy Bellay on 10/11/15.
//  Copyright © 2015 Timothy Bellay. All rights reserved.
//

#import "MMMineSweeperGrid.h"
#import "MMMineSweeperTile.h"

#define kRowKey @"row"
#define kColKey @"col"

@interface MMMineSweeperGrid ()
@property (readwrite, assign, nonatomic) MMSize size;
@property (strong, nonatomic) NSArray *tileGrid; // of MMMineSweeperTile.
@property (assign, nonatomic) NSInteger numberOfTiles;
@property (assign, nonatomic) NSInteger numberOfMines;
@property (assign, nonatomic) int minesFlagged;
@property (strong, nonatomic) NSArray *mineLocations; // of NSNumber.
@property (assign, nonatomic) BOOL gameOver;
@property (assign, nonatomic) BOOL godModeOn;

+ (NSArray *)assignMines:(NSInteger)mineCount toTiles:(NSInteger)tileCount;
@end

@implementation MMMineSweeperGrid

#pragma mark - Initialization

- (instancetype)init8x8GridWith10mines {
	return [self initGridWithRows:8 cols:8 mines:10];
//	return [self initGridWithRows:16 cols:16 mines:40];
}

- (instancetype)initGridWithRows:(int)rows cols:(int)cols mines:(int)mines {
	self = [super init];

	if (self) {
		_gameOver = NO;
		_godModeOn = NO;
		_size.rows = rows;
		_size.cols = cols;
		_numberOfTiles = self.size.rows * self.size.cols;
		_numberOfMines = mines;
		
		self.mineLocations = [[self class] assignMines:self.numberOfMines toTiles:self.numberOfTiles];
		
		// Setup grid of tiles and mark those have a bomb. TB.
		NSMutableArray *grid = [[NSMutableArray alloc] initWithCapacity:self.size.cols];
		
		for (int row = 0; row < self.size.rows; row++) {
			NSMutableArray *newRow = [[NSMutableArray alloc] initWithCapacity:self.size.rows];
			for (int col = 0; col < self.size.cols; col++) {
				NSDictionary *subscript = [MMMineSweeperGrid makeSubfromRow:row andCol:col];
				NSInteger ind = [MMMineSweeperGrid convertSubscript:subscript fromSize:self.size];
				
				MMMineSweeperTile *tile = [[MMMineSweeperTile alloc] init];
				tile.selected = NO;
				if ([self.mineLocations containsObject:[NSNumber numberWithInteger:ind]]) {
					tile.hasMine = YES;
//					NSLog(@"ind: %li MINE", (long)ind); // Debug. TB.
				} else {
					tile.hasMine = NO;
//					NSLog(@"ind: %li", (long)ind);  // Debug. TB.
				}
				[newRow addObject:tile];
			}
			[grid addObject:[newRow copy]];
		}
		self.tileGrid = [grid copy];
		
		// Set tile pointers for each 8 neighbors. TB.
		for (int row = 0; row < self.size.rows; row++) {
			for (int col = 0; col < self.size.cols; col++) {
				NSArray *tileRow = self.tileGrid[row];
				MMMineSweeperTile *tile = tileRow[col];
			
				if (row > 0 && col > 0) {
					// Left, upper.
					NSArray *upperRow = self.tileGrid[row-1];
					tile.leftUp = upperRow[col-1];
				}
				if (row > 0) {
					// Upper.
					NSArray *upperRow = self.tileGrid[row-1];
					tile.up = upperRow[col];
				}
				if (row > 0 && col < self.size.cols - 1) {
					// Right, upper.
					NSArray *upperRow = self.tileGrid[row-1];
					tile.rightUp = upperRow[col+1];
				}
				if (col < self.size.cols - 1) {
					// Right.
					tile.right = tileRow[col+1];
				}
				if (row < self.size.rows - 1 && col < self.size.cols - 1) {
					// Right, lower.
					NSArray *lowerRow = self.tileGrid[row+1];
					tile.rightDown = lowerRow[col+1];
				}
				if (row < self.size.rows - 1) {
					// Lower.
					NSArray *lowerRow = self.tileGrid[row+1];
					tile.down = lowerRow[col];
				}
				if (row < self.size.rows - 1 && col > 0) {
					// Left, lower.
					NSArray *lowerRow = self.tileGrid[row+1];
					tile.leftDown = lowerRow[col-1];
				}
				if (col > 0) {
					// Left.
					tile.left = tileRow[col-1];
				}
			}
		}
		
		// Set neighborhood mine count for each tile. TB.
		for (int row = 0; row < self.size.rows; row++) {
			for (int col = 0; col < self.size.cols; col++) {
				MMMineSweeperTile *tile = [self getTileAtRow:row col:col];
				tile.nearbyMineCount = tile.leftUp.hasMine + tile.up.hasMine + tile.rightUp.hasMine + tile.right.hasMine + tile.rightDown.hasMine + tile.down.hasMine + tile.leftDown.hasMine + tile.left.hasMine;
			}
		}
	}
	return self;
}

+ (NSArray *)assignMines:(NSInteger)mineCount toTiles:(NSInteger)tileCount {
	NSMutableArray *mines = [[NSMutableArray alloc] init];
	do {
		NSNumber *randomTile = [NSNumber numberWithInteger:arc4random_uniform(tileCount)];
		if (![mines containsObject:randomTile]) {
			[mines addObject:randomTile];
		}
	} while ([mines count] < mineCount);
	return [mines copy];
}


#pragma mark - Game state methods

- (NSInteger)getNumberOfMines {
	return self.numberOfMines;
}

- (BOOL)hasMineAtRow:(NSInteger)row col:(NSInteger)col {
	MMMineSweeperTile *tile = [self getTileAtRow:row col:col];
	return tile.hasMine;
}

- (BOOL)isTileSelectedAtRow:(NSInteger)row col:(NSInteger)col {
	MMMineSweeperTile *tile = [self getTileAtRow:row col:col];
	return tile.selected;
}

- (BOOL)isTileFlaggedAtRow:(NSInteger)row col:(NSInteger)col {
	MMMineSweeperTile *tile = [self getTileAtRow:row col:col];
	return tile.flagged;
}


- (NSInteger)getMineCountForTileAtRow:(NSInteger)row col:(NSInteger)col {
	MMMineSweeperTile *tile = [self getTileAtRow:row col:col];
	return tile.nearbyMineCount;
};

- (void)didTapTile:(MMMineSweeperTile *)tile {
	if (tile.hasMine) {
		tile.selected = YES;
		[self endGame];
	} else if (tile && !tile.hasMine && tile.nearbyMineCount > 0) {
		tile.selected = YES;
	} else if (tile && !tile.hasMine && tile.nearbyMineCount == 0) {
		tile.selected = YES;
		if (!tile.leftUp.hasMine && !tile.leftUp.selected) {
			[self didTapTile:tile.leftUp];
		}
		if (!tile.up.hasMine && !tile.up.selected) {
			[self didTapTile:tile.up];
		}
		if (!tile.rightUp.hasMine && !tile.rightUp.selected) {
			[self didTapTile:tile.rightUp];
		}
		if (!tile.right.hasMine && !tile.right.selected) {
			[self didTapTile:tile.right];
		}
		if (!tile.rightDown.hasMine && !tile.rightDown.selected) {
			[self didTapTile:tile.rightDown];
		}
		if (!tile.down.hasMine && !tile.down.selected) {
			[self didTapTile:tile.down];
		}
		if (!tile.leftDown.hasMine && !tile.leftDown.selected) {
			[self didTapTile:tile.leftDown];
		}
		if (!tile.left.hasMine && !tile.left.selected) {
			[self didTapTile:tile.left];
		}
	}
}

- (void)didTapTileAtRow:(NSInteger)row col:(NSInteger)col {
	MMMineSweeperTile *tile = [self getTileAtRow:row col:col];
	[self didTapTile:tile];
}

- (void)didLongPressTileAtRow:(NSInteger)row col:(NSInteger)col {
	MMMineSweeperTile *tile = [self getTileAtRow:row col:col];
	tile.flagged = !tile.flagged;
	
}



- (void)endGame {
	for (NSNumber * ind in self.mineLocations) {
		NSDictionary *subscript = [[self class] convertIndex:ind.integerValue fromSize:self.size];
		
		NSNumber *col = [subscript valueForKey:kColKey];
		NSNumber *row = [subscript valueForKey:kRowKey];
		
		MMMineSweeperTile * tile = [self getTileAtRow:row.integerValue col:col.integerValue];
		tile.selected = YES;
	}
	self.gameOver = YES;
}

- (BOOL)isGameOver {
	return self.gameOver;
}

- (BOOL)isGameValidated {
	NSMutableSet *nonMineLocatons = [[NSMutableSet alloc] initWithCapacity:self.numberOfTiles];
	for (int i = 0; i < self.numberOfTiles; i++) {
		NSNumber *index = [NSNumber numberWithInteger:i];
		[nonMineLocatons addObject:index];
	}
	for (NSNumber *index in self.mineLocations) {
		[nonMineLocatons removeObject:index];
	}
	
	NSSet *selectedTiles = [self getAllSelectedTileIndices];
	
	[nonMineLocatons minusSet:selectedTiles];
	
	if (nonMineLocatons.count > 0) {
		[self endGame];
		return NO;
	}
	return YES;
}

- (BOOL)isGodModeOn {
	return self.godModeOn;
}

- (void)toggleGodMode {
	self.godModeOn = !self.godModeOn;
}


#pragma mark Helpers
+ (NSDictionary *)makeSubfromRow:(NSInteger)row andCol:(NSInteger)col {
	NSMutableDictionary *sub = [[NSMutableDictionary alloc] init];
	[sub setValue:[NSNumber numberWithInteger:row] forKey:kRowKey];
	[sub setValue:[NSNumber numberWithInteger:col] forKey:kColKey];
	return [sub copy];
}

+ (NSDictionary *)convertIndex:(NSInteger)ind fromSize:(MMSize)size{
	NSMutableDictionary *sub = [[NSMutableDictionary alloc] init];
	NSInteger maxInd = (size.rows * size.cols) - 1;
	if (ind < 0) {
		[sub setValue:nil forKey:kRowKey];
		[sub setValue:nil forKey:kColKey];
	} else if (ind > maxInd) {
		[sub setValue:[NSNumber numberWithInteger:size.rows - 1 ] forKey:kRowKey];
		[sub setValue:[NSNumber numberWithInteger:size.cols - 1 ] forKey:kColKey];
	} else {
		[sub setValue:[NSNumber numberWithInteger:(ind/size.cols)] forKey:kRowKey];
		[sub setValue:[NSNumber numberWithInteger:(ind % size.cols)] forKey:kColKey];
	}
	return [sub copy];
}

+ (NSInteger)convertSubscript:(NSDictionary *)sub fromSize:(MMSize)size {
	NSNumber *row = sub[kRowKey];
	NSNumber *col = sub[kColKey];
	NSInteger ind = ((size.rows * row.integerValue) + col.integerValue);
	return ind;
}

- (MMMineSweeperTile *)getTileAtRow:(NSInteger)row col:(NSInteger)col {
	MMMineSweeperTile *tile;
	if (row <= self.size.rows && col <= self.size.cols) {
		NSArray *tileRow = self.tileGrid[row];
		tile = tileRow[col];
		return tile;
	}
	return tile;
}

- (NSSet *)getAllSelectedTileIndices {
	NSMutableSet *selectedTiles = [[NSMutableSet alloc] init];
	for (int row = 0; row < self.size.rows; row++) {
		for (int col = 0; col < self.size.cols; col++) {
			MMMineSweeperTile *tile = [self getTileAtRow:row col:col];
			if (tile.selected) {
				NSDictionary *sub = [[self class] makeSubfromRow:row andCol:col];
				NSInteger ind = [[self class] convertSubscript:sub fromSize:self.size];
				[selectedTiles addObject:[NSNumber numberWithInteger:ind]];
			}
		}
	}
	return [selectedTiles copy];
}

@end
