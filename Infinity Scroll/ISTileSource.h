//
//  ISTileSource.h
//  Infinity Scroll
//
//  Created by Justin R. Miller on 11/26/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    NSUInteger z;
    NSUInteger x;
    NSUInteger y;
} ISTile;

@interface ISTileSource : NSObject

+ (UIImage *)imageForTile:(ISTile)tile;

ISTile ISTileMake(NSUInteger z, NSUInteger x, NSUInteger y);

NSString *ISTileKey(ISTile tile);

@end
