//
//  MaderaTrianglesView.m
//  MaderaTriangles
//
//  Created by Erik Doernenburg on 24/11/2019.
//Copyright © 2019 Mulle Kybernetik. All rights reserved.
//

#import "MaderaTrianglesView.h"

@implementation MaderaTrianglesView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
