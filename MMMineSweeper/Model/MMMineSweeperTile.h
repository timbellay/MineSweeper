//
//  MMMineSweeperTile.h
//  MMMineSweeper
//
//  Created by Timothy Bellay on 10/11/15.
//  Copyright © 2015 Timothy Bellay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMMineSweeperTile : NSObject
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL flagged;


@property (strong, nonatomic) MMMineSweeperTile *left;
@property (strong, nonatomic) MMMineSweeperTile *right;
@property (strong, nonatomic) MMMineSweeperTile *up;
@property (strong, nonatomic) MMMineSweeperTile *down;
@property (strong, nonatomic) MMMineSweeperTile *leftUp;
@property (strong, nonatomic) MMMineSweeperTile *leftDown;
@property (strong, nonatomic) MMMineSweeperTile *rightUp;
@property (strong, nonatomic) MMMineSweeperTile *rightDown;
@property (assign, nonatomic) BOOL hasMine;
@property (assign, nonatomic) NSInteger nearbyMineCount;

@end
