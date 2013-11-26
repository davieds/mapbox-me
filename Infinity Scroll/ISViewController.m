//
//  ISViewController.m
//  Infinity Scroll
//
//  Created by Justin R. Miller on 11/26/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "ISViewController.h"

@implementation ISViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 512) / 2, (self.view.bounds.size.height - 512) / 2, 512, 512)];
    scrollView.contentSize = CGSizeMake(1024, 1024);
    scrollView.scrollEnabled = YES;
    scrollView.bounces = NO;
    scrollView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:scrollView];

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
    contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LoadingTile6.png"]];
    [scrollView addSubview:contentView];
}

@end
