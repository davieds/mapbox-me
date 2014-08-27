//
//  MBMViewController.m
//  Mapbox Me
//
//  Copyright (c) 2014 Mapbox, Inc. All rights reserved.
//

#import "MBMViewController.h"

#import "Mapbox.h"

#define kRegularSourceID   @"examples.map-z2effxa8"
#define kTerrainSourceID   @"examples.map-zgrqqx0w"
#define kSatelliteSourceID @"examples.map-zyt2v9k2"

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
    
    self.title = @"Mapbox Me";
    
    [self.segmentedControl addTarget:self action:@selector(toggleMode:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    [[UINavigationBar appearance] setTintColor:kTintColor];
    [[UISegmentedControl appearance] setTintColor:kTintColor];
    [[UIToolbar appearance] setTintColor:kTintColor];

    [[RMConfiguration configuration] setAccessToken:@"pk.eyJ1IjoianVzdGluIiwiYSI6IlpDbUJLSUEifQ.4mG8vhelFMju6HpIY-Hi5A"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.mapView.tileSource = [[RMMapboxSource alloc] initWithMapID:kRegularSourceID];

    self.navigationItem.rightBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];

    self.navigationItem.rightBarButtonItem.tintColor = kTintColor;

    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

#pragma mark -

- (void)toggleMode:(UISegmentedControl *)sender
{
    NSString *mapID;
    
    if (sender.selectedSegmentIndex == 2)
        mapID = kSatelliteSourceID;
    else if (sender.selectedSegmentIndex == 1)
        mapID = kTerrainSourceID;
    else if (sender.selectedSegmentIndex == 0)
        mapID = kRegularSourceID;
    
    self.mapView.tileSource = [[RMMapboxSource alloc] initWithMapID:mapID];
}

@end