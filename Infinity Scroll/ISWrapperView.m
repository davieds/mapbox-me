//
//  ISWrapperView.m
//  Infinity Scroll
//
//  Created by Justin R. Miller on 11/26/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "ISWrapperView.h"

#import <GLKit/GLKit.h>

@protocol ISScrollViewDelegate <UIScrollViewDelegate>

@optional

- (void)scrollViewWillRecenter:(UIScrollView *)scrollView;
- (void)scrollViewDidRecenter:(UIScrollView *)scrollView;

@end

#pragma mark -

@interface ISScrollView : UIScrollView

@property (nonatomic, weak) id<ISScrollViewDelegate>delegate;

@end

@implementation ISScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];

    if ((fabs(self.contentOffset.x - ((self.contentSize.width  - self.bounds.size.width)  / 2.0)) > self.contentSize.width  / 4.0) ||
        (fabs(self.contentOffset.y - ((self.contentSize.height - self.bounds.size.height) / 2.0)) > self.contentSize.height / 4.0))
    {
        if ([self.delegate respondsToSelector:@selector(scrollViewWillRecenter:)])
            [self.delegate scrollViewWillRecenter:self];

        self.contentOffset = CGPointMake(self.bounds.size.width, self.bounds.size.height);

        if ([self.delegate respondsToSelector:@selector(scrollViewDidRecenter:)])
            [self.delegate scrollViewDidRecenter:self];
    }
}

@end

#pragma mark -

@interface ISWrapperView () <ISScrollViewDelegate, GLKViewDelegate>

@property (nonatomic) ISScrollView *scrollView;
@property (nonatomic) UIView *contentView;
@property (nonatomic) CGFloat worldZoom;
@property (nonatomic) CGFloat worldDimension;
@property (nonatomic) CGPoint worldOffset;
@property (nonatomic) CGPoint lastContentOffset;
@property (nonatomic, getter=isRecentering) BOOL recentering;

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

        _worldZoom = log2f(self.bounds.size.width / 256);
        _worldDimension = self.bounds.size.width;
        _worldOffset = CGPointMake(0, 0);

        _lastContentOffset = _scrollView.contentOffset;
    }

    return self;
}

#pragma mark -

- (CGPoint)clampedWorldOffset:(CGPoint)offset
{
    CGFloat maxDimension = powf(2.0, self.worldZoom) * 256;

    CGFloat newX = offset.x;

    if (newX > maxDimension)
        newX -= maxDimension;

    if (newX < 0)
        newX += maxDimension;

    CGFloat newY = offset.y;

    if (newY > maxDimension)
        newY = maxDimension;

    if (newY < 0)
        newY = 0;

    return CGPointMake(newX, newY);
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRecentering)
        return;

    CGFloat dx = self.scrollView.contentOffset.x - self.lastContentOffset.x;
    CGFloat dy = self.scrollView.contentOffset.y - self.lastContentOffset.y;

    self.worldOffset = [self clampedWorldOffset:CGPointMake(self.worldOffset.x + dx, self.worldOffset.y + dy)];

    NSLog(@"world offset: %@", [NSValue valueWithCGPoint:self.worldOffset]);

    self.lastContentOffset = self.scrollView.contentOffset;
}

- (void)scrollViewWillRecenter:(UIScrollView *)scrollView
{
    self.recentering = YES;
}

- (void)scrollViewDidRecenter:(UIScrollView *)scrollView
{
    self.recentering = NO;

    self.lastContentOffset = scrollView.contentOffset;
}

#pragma mark -

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
}

@end
