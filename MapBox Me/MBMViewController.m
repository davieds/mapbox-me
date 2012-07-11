//
//  MBMViewController.m
//  MapBox Me
//
//  Created by Justin Miller on 3/29/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "MBMViewController.h"

#import "RMMapView.h"
#import "RMMapBoxSource.h"
#import "RMUserTrackingBarButtonItem.h"

#define kNormalRegularSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-s2effxa8.jsonp"]
#define kRetinaRegularSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-kswgei2n.jsonp"]
#define kNormalTerrainSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-ngrqqx0w.jsonp"]
#define kRetinaTerrainSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-nq0f1vuc.jsonp"]

#define kTintColor [UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000]

@interface MBMViewController ()

@property (nonatomic, strong) IBOutlet RMMapView *mapView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@end

#pragma mark -

@implementation MBMViewController

@synthesize mapView;
@synthesize segmentedControl;

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
    self.mapView.decelerationMode = RMMapDecelerationFast;
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    self.mapView.minZoom = 1;
    self.mapView.zoom = 2;
    self.mapView.backgroundColor = kTintColor;
    self.mapView.viewControllerPresentingAttribution = self;
    
    self.navigationItem.rightBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];

    self.navigationItem.rightBarButtonItem.tintColor = kTintColor;
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

@end