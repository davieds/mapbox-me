//
//  ISWrapperView.m
//  Infinity Scroll
//
//  Created by Justin R. Miller on 11/26/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "ISWrapperView.h"

#import <GLKit/GLKit.h>

@interface ISWrapperView () <UIScrollViewDelegate, GLKViewDelegate>

@property UIScrollView *scrollView;
@property GLKView *contentView;

@end

#pragma mark -

@implementation ISWrapperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.contentSize = CGSizeMake(1024, 1024);
        _scrollView.scrollEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = [UIColor darkGrayColor];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];

        _contentView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
        _contentView.delegate = self;
        [_scrollView addSubview:_contentView];
    }

    return self;
}

#pragma mark -

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{

}

@end
