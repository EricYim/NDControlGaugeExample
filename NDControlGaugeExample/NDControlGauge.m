/*
 * NDControlGauge.m
 *
 * Copyright 2011 Eric Yim.
 * Created by Eric Yim on 11-09-16.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 * IN THE SOFTWARE.
 *
 */

#import "NDControlGauge.h"

@interface NDControlGauge (PrivateMethods)
/** Releases gauge from selected state */
- (void)resetState;
@end

@implementation NDControlGauge

@synthesize level = level_;

+ (id)gaugeWithFrameNormalSprite:(CCSprite *)frameNormalSprite contentNormalSprite:(CCSprite *)contentNormalSprite {
    return [[[self alloc] initWithFrameNormalSprite:frameNormalSprite contentNormalSprite:contentNormalSprite] autorelease];
}

+ (id)gaugeWithFrameNormalSprite:(CCSprite *)frameNormalSprite frameDisabledSprite:(CCSprite *)frameDisabledSprite contentNormalSprite:(CCSprite *)contentNormalSprite contentDisabledSprite:(CCSprite *)contentDisabledSprite {
    return [[[self alloc] initWithFrameNormalSprite:frameNormalSprite frameDisabledSprite:frameDisabledSprite contentNormalSprite:contentNormalSprite contentDisabledSprite:contentDisabledSprite] autorelease];
}

- (id)initWithFrameNormalSprite:(CCSprite *)frameNormalSprite contentNormalSprite:(CCSprite *)contentNormalSprite {
    // Duplicates normalSprite since no disabled sprite is provided.
    CCSprite *frameDisabledSprite = [CCSprite spriteWithTexture:frameNormalSprite.texture];
    // Dims disabled sprite
    frameDisabledSprite.color = ccc3(150, 150, 150);
    
    CCSprite *contentDisabledSprite = [CCSprite spriteWithTexture:contentNormalSprite.texture];
    // Dims disabled sprite
    contentDisabledSprite.color = ccc3(150, 150, 150);
    
    return [self initWithFrameNormalSprite:frameNormalSprite frameDisabledSprite:frameDisabledSprite contentNormalSprite:contentNormalSprite contentDisabledSprite:contentDisabledSprite];
}

// Designated init
- (id)initWithFrameNormalSprite:(CCSprite *)frameNormalSprite frameDisabledSprite:(CCSprite *)frameDisabledSprite contentNormalSprite:(CCSprite *)contentNormalSprite contentDisabledSprite:(CCSprite *)contentDisabledSprite
{
    // Prohibits nil params
    NSAssert(frameNormalSprite != nil, @"Attempt to initialize gauge with nil normal frame sprite.");
    NSAssert(frameDisabledSprite != nil, @"Attempt to initialize gauge with nil disabled frame sprite.");
    NSAssert(contentNormalSprite != nil, @"Attempt to initialize gauge with nil normal content sprite.");
    NSAssert(contentDisabledSprite != nil, @"Attempt to initialize gauge with nil disabled frame sprite.");
    self = [super init];
    if (self) {
        // Sets gauge's content size as normal content sprite's
        self.contentSize =  contentNormalSprite.contentSize;
        // Centers frame on node's anchor
        frameNormalSprite.position = self.childrenAnchorPointInPixels;
        [self addChild:frameNormalSprite z:2 tag:kFrameNormalSpriteTag];
        
        frameDisabledSprite.position = self.childrenAnchorPointInPixels;
        // Hides disabled frame sprite
        frameDisabledSprite.visible = NO;
        [self addChild:frameDisabledSprite z:2 tag:kFrameDisabledSpriteTag];
        
        // Sets content's anchor on center-left
        contentNormalSprite.anchorPoint = CGPointMake(0, 0.5f);
        // Centers content on node's anchor
        contentNormalSprite.position = CGPointMake(0, self.childrenAnchorPointInPixels.y);
        [self addChild:contentNormalSprite z:1 tag:kContentNormalSpriteTag];
        
        // Sets content's anchor on center-left
        contentDisabledSprite.anchorPoint = CGPointMake(0, 0.5f);
        // Centers content on node's anchor
        contentDisabledSprite.position = CGPointMake(0, self.childrenAnchorPointInPixels.y);
        // Hides disabled content sprite
        contentDisabledSprite.visible = NO;
        [self addChild:contentDisabledSprite z:1 tag:kContentDisabledSpriteTag];
        
        minX_ = -0.5f * self.contentSize.width;
        maxX_ = 0.5f * self.contentSize.width;
        
        level_ = -1;
        self.level = 0;
    }
    
    return self;
}

#pragma mark Properties

- (void)setEnabled:(BOOL)enabled {
    if (enabled != enabled_) {
        enabled_ = enabled;
        
        CCSprite *contentNormalSprite = (CCSprite *)[self getChildByTag:kContentNormalSpriteTag];
        CCSprite *contentDisabledSprite = (CCSprite *)[self getChildByTag:kContentDisabledSpriteTag];
        
        CCSprite *frameNormalSprite = (CCSprite *)[self getChildByTag:kFrameNormalSpriteTag];
        CCSprite *frameDisabledSprite = (CCSprite *)[self getChildByTag:kFrameDisabledSpriteTag];
        
        // Sets correct state
        if (!enabled) {
            state_ = CCControlStateDisabled;
            contentDisabledSprite.textureRect = contentNormalSprite.textureRect;
        }
        else {
            state_ = CCControlStateNormal;
        }
        // Shows and hides the appropriate sprites
        frameNormalSprite.visible = enabled;
        frameDisabledSprite.visible = !enabled;
        contentNormalSprite.visible = enabled;
        contentDisabledSprite.visible = !enabled;
    }
}

- (void)setLevel:(float)newLevel {
    if (self.enabled) {
        // Bounds newLevel to [0,1] 
        if (newLevel < 0) {
            newLevel = 0;
        }
        else if (newLevel > 1.0f) {
            newLevel = 1.0f;
        }
        if (level_ != newLevel) {
            level_ = newLevel;
            
            // Stretches content proportional to newLevel
            CCSprite *contentNormalSprite = (CCSprite *)[self getChildByTag:kContentNormalSpriteTag];
            float width = self.childrenAnchorPointInPixels.x + minX_ + level_ * (maxX_ - minX_);
            CGRect textureRect = contentNormalSprite.textureRect;
            textureRect = CGRectMake(textureRect.origin.x, textureRect.origin.y, width, textureRect.size.height);
            contentNormalSprite.textureRect = textureRect;
            
            // Sends value changed event related actions
            [self sendActionsForControlEvents:CCControlEventValueChanged];
        }
    }
}

#pragma mark Public methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (float)levelForTouch:(UITouch *)touch {
    float retVal;
    
    CGPoint touchLocation = [self convertTouchToNodeSpaceAR:touch];
    
    if (touchLocation.x < minX_)
    {
        touchLocation.x = minX_;
    } else if (touchLocation.x > maxX_)
    {
        touchLocation.x = maxX_;
    }
    
    retVal = (touchLocation.x - minX_) / (maxX_ - minX_);
    
    return retVal;
}

#endif

#pragma mark -
#pragma mark Touch Handling

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL retVal = NO;
    
    if (self.enabled && [self isTouchInside:touch]) {
        [self sendActionsForControlEvents:CCControlEventTouchDown];
        retVal = YES;
        self.selected = YES;
        state_ = CCControlStateSelected;
        self.level = [self levelForTouch:touch];
    }
    
    return retVal;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    self.level = [self levelForTouch:touch];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self sendActionsForControlEvents:CCControlEventTouchUpInside | CCControlEventTouchUpOutside];
    [self resetState];
    self.level = [self levelForTouch:touch];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self resetState];
    [self sendActionsForControlEvents:CCControlEventTouchCancel];
}

#endif

@end

@implementation NDControlGauge (PrivateMethods)

- (void)resetState {
    self.selected = NO;
    state_ = CCControlStateNormal;
}

@end