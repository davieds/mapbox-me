//
//  ISWrapperView.m
//  Infinity Scroll
//
//  Created by Justin R. Miller on 11/26/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "ISWrapperView.h"

#import <GLKit/GLKit.h>

@interface ISScrollView : UIScrollView

@end

@implementation ISScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];

    if ((fabs(self.contentOffset.x - ((self.contentSize.width  - self.bounds.size.width)  / 2.0)) > self.contentSize.width  / 4.0) ||
        (fabs(self.contentOffset.y - ((self.contentSize.height - self.bounds.size.height) / 2.0)) > self.contentSize.height / 4.0))
    {
        self.contentOffset = CGPointMake(self.bounds.size.width, self.bounds.size.height);
    }
}

@end

#pragma mark -

@interface ISWrapperView () <UIScrollViewDelegate, GLKViewDelegate>

@property ISScrollView *scrollView;
@property UIView *contentView;

@end

#pragma mark -

@implementation ISWrapperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        _scrollView = [[ISScrollView alloc] initWithFrame:self.bounds];
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.width * 3);
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, self.bounds.size.height);
        _scrollView.scrollEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];

        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height)];
//        _contentView.delegate = self;
        _contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile.png"]];
        [_scrollView addSubview:_contentView];
    }

    return self;
}

#pragma mark -

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
}

@end
