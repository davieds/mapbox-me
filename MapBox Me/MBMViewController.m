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

#define kNormalSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-s2effxa8.jsonp"]
#define kRetinaSourceURL [NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/justin.map-kswgei2n.jsonp"]

@interface MBMViewController ()

@property (nonatomic, strong) IBOutlet RMMapView *mapView;

@end

#pragma mark -

@implementation MBMViewController

@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"MapBox Me";
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000];
    
    CGRect mapRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    RMMapBoxSource *tileSource = [[RMMapBoxSource alloc] initWithReferenceURL:(([[UIScreen mainScreen] scale] > 1.0) ? kRetinaSourceURL : kNormalSourceURL)];
    
    self.mapView = [[RMMapView alloc] initWithFrame:mapRect andTilesource:tileSource];
    
    self.mapView.decelerationMode = RMMapDecelerationFast;
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    self.mapView.minZoom = 1;
    self.mapView.zoom = 2;
    self.mapView.backgroundColor = [UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:0.5];
    self.mapView.viewControllerPresentingAttribution = self;
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.mapView];
    
    self.navigationItem.rightBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    self.navigationItem.rightBarButtonItem.tintColor = self.navigationController.navigationBar.tintColor;
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

@end