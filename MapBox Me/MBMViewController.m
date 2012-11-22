//
//  MBMViewController.m
//  MapBox Me
//
//  Created by Justin Miller on 3/29/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "MBMViewController.h"

#import "MapBox.h"

#define kNormalRegularSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-s2effxa8.jsonp"]
#define kRetinaRegularSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-kswgei2n.jsonp"]
#define kNormalTerrainSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-ngrqqx0w.jsonp"]
#define kRetinaTerrainSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-nq0f1vuc.jsonp"]

#define kTintColor [UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000]

@interface MBMViewController ()

@property (nonatomic, strong) IBOutlet RMMapView *mapView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIProgressView *cacheProgressView;

@end

#pragma mark -

@implementation MBMViewController

@synthesize mapView;
@synthesize segmentedControl;
@synthesize cacheProgressView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"MapBox Me";
    
    [self.segmentedControl addTarget:self action:@selector(toggleMode:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    [[UINavigationBar appearance] setTintColor:kTintColor];
    [[UISegmentedControl appearance] setTintColor:kTintColor];
    [[UIToolbar appearance] setTintColor:kTintColor];

    self.mapView.tileSource = [[RMMapBoxSource alloc] initWithReferenceURL:(([[UIScreen mainScreen] scale] > 1.0) ? kRetinaRegularSourceURL : kNormalRegularSourceURL)];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    self.mapView.minZoom = 1;
    self.mapView.zoom = 2;

    self.mapView.tileCache = [[RMTileCache alloc] initWithExpiryPeriod:(60 * 60 * 24 * 7)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cache" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleCache:)];

    self.navigationItem.rightBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];

    self.navigationItem.rightBarButtonItem.tintColor = kTintColor;

    self.mapView.delegate = (id <RMMapViewDelegate>)self;
    self.mapView.tileCache.backgroundCacheDelegate = (id <RMTileCacheBackgroundDelegate>)self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

#pragma mark -

- (void)toggleMode:(UISegmentedControl *)sender
{
    BOOL isRetina  = ([[UIScreen mainScreen] scale] > 1.0);
    BOOL isTerrain = (sender.selectedSegmentIndex == 1);
    
    NSURL *tileURL;
    
    if (isRetina && isTerrain)
        tileURL = kRetinaTerrainSourceURL;
    else if (isRetina && ! isTerrain)
        tileURL = kRetinaRegularSourceURL;
    else if (! isRetina && isTerrain)
        tileURL = kNormalTerrainSourceURL;
    else if (! isRetina && ! isTerrain)
        tileURL = kNormalRegularSourceURL;
    
    self.mapView.tileSource = [[RMMapBoxSource alloc] initWithReferenceURL:tileURL];
}

- (void)toggleCache:(id)sender
{
    if ( ! self.mapView.tileCache.isBackgroundCaching)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Background Cache?"
                                                        message:@"Begin background caching of the visible map area?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Begin", nil];

        alert.tag = 1;

        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancel Cache?"
                                                        message:@"Cancel background caching?"
                                                       delegate:self
                                              cancelButtonTitle:@"Don't Cancel"
                                              otherButtonTitles:@"Cancel", @"Cancel and Clear Cache", nil];

        alert.tag = 2;

        [alert show];
    }
}

#pragma mark -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == alertView.firstOtherButtonIndex)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleCache:)];

        [self.mapView.tileCache beginBackgroundCacheForTileSource:self.mapView.tileSource
                                                        southWest:[self.mapView latitudeLongitudeBoundingBox].southWest
                                                        northEast:[self.mapView latitudeLongitudeBoundingBox].northEast
                                                          minZoom:self.mapView.zoom
                                                          maxZoom:[self.mapView.tileSource maxZoom]];
    }
    else if (alertView.tag == 2)
    {
        if (self.mapView.tileCache.isBackgroundCaching)
        {
            if (buttonIndex == alertView.firstOtherButtonIndex || buttonIndex == alertView.firstOtherButtonIndex + 1)
            {
                self.navigationItem.leftBarButtonItem.enabled = NO;

                [self.mapView.tileCache cancelBackgroundCache];

                if (buttonIndex == alertView.firstOtherButtonIndex + 1)
                    [self.mapView removeAllCachedImages];
            }
        }
    }
}

#pragma mark -

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    NSLog(@"%f, %f", map.centerCoordinate.latitude, map.centerCoordinate.longitude);
}

#pragma mark -

- (void)tileCache:(RMTileCache *)tileCache didBeginBackgroundCacheWithCount:(int)tileCount forTileSource:(id <RMTileSource>)tileSource
{
    NSLog(@"begin cache of %@ with %i tiles", [tileSource shortName], tileCount);

    self.cacheProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];

    self.navigationItem.titleView = self.cacheProgressView;
}

- (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(int)tileIndex ofTotalTileCount:(int)totalTileCount
{
    NSLog(@"cached tile %i,%i,%i (%i of %i)", tile.zoom, tile.x, tile.y, tileIndex, totalTileCount);

    [self.cacheProgressView setProgress:((float)tileIndex / (float)totalTileCount) animated:YES];
}

- (void)tileCacheDidFinishBackgroundCache:(RMTileCache *)tileCache
{
    NSLog(@"cache finished");

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cache" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleCache:)];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.titleView = nil;

    [[[UIAlertView alloc] initWithTitle:@"Cache Complete"
                                message:@"The cache completed successfully."
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)tileCacheDidCancelBackgroundCache:(RMTileCache *)tileCache
{
    NSLog(@"cache cancelled");

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cache" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleCache:)];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.titleView = nil;
}

@end