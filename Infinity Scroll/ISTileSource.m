//
//  ISTileSource.m
//  Infinity Scroll
//
//  Created by Justin R. Miller on 11/26/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "ISTileSource.h"

#define kMapID @"justin.map-pgygbwdm"
#define kTileTemplateURL @"https://a.tiles.mapbox.com/v3/{mapID}/{z}/{x}/{y}.png"

@implementation ISTileSource

+ (UIImage *)imageForTile:(ISTile)tile
{
    NSString *tileCachePath = [NSString stringWithFormat:@"%@%@_%@.png", NSTemporaryDirectory(), kMapID, ISTileKey(tile)];

    if ([[NSFileManager defaultManager] fileExistsAtPath:tileCachePath])
        return [UIImage imageWithContentsOfFile:tileCachePath];

    NSString *tileURLString = kTileTemplateURL;
    tileURLString = [tileURLString stringByReplacingOccurrencesOfString:@"{mapID}" withString:kMapID];
    tileURLString = [tileURLString stringByReplacingOccurrencesOfString:@"{z}" withString:[@(tile.z) stringValue]];
    tileURLString = [tileURLString stringByReplacingOccurrencesOfString:@"{x}" withString:[@(tile.x) stringValue]];
    tileURLString = [tileURLString stringByReplacingOccurrencesOfString:@"{y}" withString:[@(tile.y) stringValue]];

    NSData *tileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tileURLString]];

    [tileData writeToFile:tileCachePath atomically:YES];

    return [UIImage imageWithData:tileData];
}

ISTile ISTileMake(NSUInteger z, NSUInteger x, NSUInteger y)
{
    ISTile tile = {
        .z = z,
        .x = x,
        .y = y,
    };

    return tile;
}

NSString *ISTileKey(ISTile tile)
{
    return [NSString stringWithFormat:@"%i_%i_%i", tile.z, tile.x, tile.y];
}

@end
