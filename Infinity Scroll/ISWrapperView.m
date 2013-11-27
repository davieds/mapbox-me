//
//  ISWrapperView.m
//  Infinity Scroll
//
//  Created by Justin R. Miller on 11/26/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "ISWrapperView.h"

#import "ISTileSource.h"

#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 position;
    GLKVector2 texture;
} SceneVertex;

typedef struct {
    SceneVertex vertices[3];
} SceneTriangle;

static SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC);

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
@property (nonatomic) GLKView *contentView;
@property (nonatomic) CGFloat worldZoom;
@property (nonatomic) CGFloat worldDimension;
@property (nonatomic) CGPoint worldOffset;
@property (nonatomic) CGPoint lastContentOffset;
@property (nonatomic, getter=isRecentering) BOOL recentering;
@property (nonatomic) GLKBaseEffect *baseEffect;
@property (nonatomic) GLuint bufferName;
@property (nonatomic) GLKTextureInfo *blankTexture;
@property (nonatomic) NSMutableDictionary *textures;
@property (nonatomic) CADisplayLink *displayLink;

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

        _contentView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height)];
        _contentView.delegate = self;
        _contentView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [_scrollView addSubview:_contentView];

        _worldZoom = log2f(self.bounds.size.width / 256);
        _worldDimension = self.bounds.size.width;
        _worldOffset = CGPointMake(0, 0);

        _lastContentOffset = _scrollView.contentOffset;

        [EAGLContext setCurrentContext:_contentView.context];

        _baseEffect = [GLKBaseEffect new];
        _baseEffect.useConstantColor = GL_TRUE;
        _baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);

        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

        glGenBuffers(1, &_bufferName);
        glBindBuffer(GL_ARRAY_BUFFER, _bufferName);

        _textures = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)dealloc
{
    if (_bufferName)
    {
        glDeleteBuffers(1, &_bufferName);
        _bufferName = 0;
    }

    [EAGLContext setCurrentContext:_contentView.context];
    _contentView.context = nil;
    [EAGLContext setCurrentContext:nil];
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

- (void)startDisplayLinkIfNeeded
{
    if ( ! self.displayLink)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
    }
}

- (void)stopDisplayLink
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)render:(CADisplayLink *)displayLink
{
    [self.contentView display];
}

#pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self startDisplayLinkIfNeeded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( ! decelerate)
        [self stopDisplayLink];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stopDisplayLink];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRecentering)
        return;

    CGFloat dx = self.scrollView.contentOffset.x - self.lastContentOffset.x;
    CGFloat dy = self.scrollView.contentOffset.y - self.lastContentOffset.y;

    self.worldOffset = [self clampedWorldOffset:CGPointMake(self.worldOffset.x + dx, self.worldOffset.y + dy)];

//    NSLog(@"world offset: %@", [NSValue valueWithCGPoint:self.worldOffset]);

    self.lastContentOffset = self.scrollView.contentOffset;

    NSUInteger cols = self.contentView.bounds.size.width  / 256;
    NSUInteger rows = self.contentView.bounds.size.height / 256;

    for (NSUInteger c = 0; c < cols; c++)
    {
        for (NSUInteger r = 0; r < rows; r++)
        {
            ISTile tile = ISTileMake(self.worldZoom, c, (1 - r));

            if ( ! [self.textures objectForKey:ISTileKey(tile)])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                {
                    UIImage *tileImage = [ISTileSource imageForTile:tile];

                    dispatch_async(dispatch_get_main_queue(), ^(void)
                    {
                        if (tileImage)
                        {
                            CFBridgingRetain((id)tileImage.CGImage);

                            [[[GLKTextureLoader alloc] initWithSharegroup:self.contentView.context.sharegroup] textureWithCGImage:tileImage.CGImage
                                                                                                                          options:@{ GLKTextureLoaderOriginBottomLeft : @YES }
                                                                                                                            queue:nil
                                                                                                                completionHandler:^(GLKTextureInfo *textureInfo, NSError *outError)
                                                                                                                {
                                                                                                                    if (textureInfo)
                                                                                                                    {
                                                                                                                        [self.textures setObject:textureInfo forKey:ISTileKey(tile)];

                                                                                                                        [self.contentView setNeedsDisplay];
                                                                                                                    }

                                                                                                                    CFBridgingRelease(tileImage.CGImage);
                                                                                                                }];
                        }
                    });
               });
            }
        }
    }
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
    glClear(GL_COLOR_BUFFER_BIT);

    NSUInteger cols = self.contentView.bounds.size.width  / 256;
    NSUInteger rows = self.contentView.bounds.size.height / 256;

    GLint tileIndex = 0;

    for (NSUInteger c = 0; c < cols; c++)
    {
        for (NSUInteger r = 0; r < rows; r++)
        {
            ISTile tile = ISTileMake(self.worldZoom, c, (1 - r));

            GLKTextureInfo *texture = [self.textures objectForKey:ISTileKey(tile)];

            if ( ! texture)
            {
                if ( ! self.blankTexture)
                {
                    self.blankTexture = [GLKTextureLoader textureWithCGImage:[[UIImage imageNamed:@"tile.png"] CGImage]
                                                                     options:@{ GLKTextureLoaderOriginBottomLeft : @YES }
                                                                       error:nil];
                }

                texture = self.blankTexture;
            }

            self.baseEffect.texture2d0.name   = texture.name;
            self.baseEffect.texture2d0.target = texture.target;

            [self.baseEffect prepareToDraw];

            CGSize tileSize = CGSizeMake(2.0 / (cols), 2.0 / rows);

            SceneTriangle triangles[(cols * rows * 2)];

            NSUInteger triangleIndex = 0;

            for (NSUInteger c = 0; c < cols; c++)
            {
                for (NSUInteger r = 0; r < rows; r++)
                {
                    SceneVertex tileVertexSW = {{((CGFloat)c * tileSize.width) - 1.0, ((CGFloat)r * tileSize.height) - 1.0, 0}, {0, 0}};
                    SceneVertex tileVertexSE = {{tileVertexSW.position.v[0] + tileSize.width, tileVertexSW.position.v[1], 0}, {1, 0}};
                    SceneVertex tileVertexNW = {{tileVertexSW.position.v[0], tileVertexSW.position.v[1] + tileSize.height, 0}, {0, 1}};
                    SceneVertex tileVertexNE = {{tileVertexSE.position.v[0], tileVertexNW.position.v[1], 0}, {1, 1}};

                    triangles[triangleIndex]       = SceneTriangleMake(tileVertexSE, tileVertexSW, tileVertexNW);
                    triangles[(triangleIndex + 1)] = SceneTriangleMake(tileVertexSE, tileVertexNW, tileVertexNE);

                    triangleIndex += 2;
                }
            }

            GLsizei    vertexCount     = sizeof(triangles) / sizeof(SceneVertex);
            GLsizeiptr stride          = sizeof(SceneVertex);
            GLsizeiptr bufferSizeBytes = stride * vertexCount;

            glBufferData(GL_ARRAY_BUFFER,
                         bufferSizeBytes,
                         triangles,
                         GL_DYNAMIC_DRAW);

            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glVertexAttribPointer(GLKVertexAttribPosition,
                                  3,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  sizeof(SceneVertex),
                                  NULL + offsetof(SceneVertex, position));

            glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
            glVertexAttribPointer(GLKVertexAttribTexCoord0,
                                  2,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  sizeof(SceneVertex),
                                  NULL + offsetof(SceneVertex, texture));

            glDrawArrays(GL_TRIANGLES,
                         tileIndex * 6,
                         6);
            
            tileIndex++;
        }
    }
}

#pragma mark -

static SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC)
{
    SceneTriangle result;

    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;

    return result;
}

@end
