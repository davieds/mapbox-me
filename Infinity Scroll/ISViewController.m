//
//  ISViewController.m
//  Infinity Scroll
//
//  Created by Justin R. Miller on 11/26/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "ISViewController.h"

#import "ISWrapperView.h"

@implementation ISViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];

    [self.view addSubview:[[ISWrapperView alloc] initWithFrame:CGRectMake(128, 128, 512, 512)]];
}

@end
