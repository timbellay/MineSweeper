//
//  MMMineSweeperGrid.h
//  MMMineSweeper
//
//  Created by Timothy Bellay on 10/11/15.
//  Copyright © 2015 Timothy Bellay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMMineSweeperGrid : NSObject

typedef struct  {
	NSInteger rows;
	NSInteger cols;
} MMSize; // NSSize no longer foundational data type? TB.

@property (readonly, assign, nonatomic) MMSize size;

- (instancetype)init8x8GridWith10mines;
+ (NSDictionary *)convertIndex:(NSInteger)ind fromSize:(MMSize)size;
+ (NSInteger)convertSubscript:(NSDictionary *)sub fromSize:(MMSize)size;
@end
