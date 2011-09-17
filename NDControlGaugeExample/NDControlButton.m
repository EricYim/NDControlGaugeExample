/*
 * NDControlButton.m
 * 
 * Copyright 2011 Eric Yim.
 * Created by Eric Yim on 11-09-04.
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

#import "NDControlButton.h"

@interface NDControlButton (PrivateMethods)
- (CCSprite *)disabledSpriteForNormalSprite:(CCSprite *)normalSprite;
@end

@implementation NDControlButton

+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite {
    return [[[self alloc] initWithNormalSprite:normalSprite] autorelease];
}

+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite disabledSprite:(CCSprite *)disabledSprite {
    return [[[self alloc] initWithNormalSprite:normalSprite disabledSprite:disabledSprite] autorelease];
}

+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite {
    return [[[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite] autorelease];
}

+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite disabledSprite:(CCSprite *)disabledSprite {
    return [[[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite] autorelease];
}

+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite highlightedSprite:(CCSprite *)highlightedSprite {
    return [[[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite highlightedSprite:highlightedSprite] autorelease];
}

+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite highlightedSprite:(CCSprite *)highlightedSprite disabledSprite:(CCSprite *)disabledSprite {
    return [[[self alloc] initWithNormalSprite:normalSprite selectedSprite:selectedSprite highlightedSprite:highlightedSprite disabledSprite:disabledSprite] autorelease];
}

// Convenient init
- (id)initWithNormalSprite:(CCSprite *)normalSprite {
    return [self initWithNormalSprite:normalSprite disabledSprite:[self disabledSpriteForNormalSprite:normalSprite]];
}

// Convenient init
- (id)initWithNormalSprite:(CCSprite *)normalSprite disabledSprite:(CCSprite *)disabledSprite {
    // Duplicates normalSprite since no selected sprite is provided.
    CCSprite *selectedSprite = [CCSprite spriteWithTexture:normalSprite.texture];
    return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite];
}

// Convenient init
- (id)initWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite {
    return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:[self disabledSpriteForNormalSprite:normalSprite]];
}

// Convenient init
- (id)initWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite disabledSprite:(CCSprite *)disabledSprite {
    CCSprite *highlightedSprite = nil;
    
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
    // Duplicates normalSprite since no highlighted sprite is provided.
    highlightedSprite = [CCSprite spriteWithTexture:normalSprite.texture];
#endif
    
    return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite highlightedSprite:highlightedSprite disabledSprite:disabledSprite];
}

// Convenient init
- (id)initWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite highlightedSprite:(CCSprite *)highlightedSprite {
    return [self initWithNormalSprite:normalSprite selectedSprite:selectedSprite highlightedSprite:highlightedSprite disabledSprite:[self disabledSpriteForNormalSprite:normalSprite]];
}

// Designated init
- (id)initWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite highlightedSprite:(CCSprite *)highlightedSprite disabledSprite:(CCSprite *)disabledSprite {
    // Prohibits nil params
    NSAssert(normalSprite != nil, @"Attempt to initialize with a nil normal sprite.");
    NSAssert(selectedSprite != nil, @"Attempt to initialize with a nil selected sprite.");
    NSAssert(disabledSprite != nil, @"Attempt to initialize with a nil disabled sprite.");
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED    
    NSAssert(highlightedSprite != nil, @"Attempt to initialize with a nil highlighted sprite.");
#endif
    self = [super init];
    if (self) {
        // Sets button's content size as normalSprite's
        self.contentSize = normalSprite.contentSize;
        // Centers sprite on control
        normalSprite.position = self.childrenAnchorPointInPixels;
        [self addChild:normalSprite z:1 tag:kNormalSpriteTag];
        
        // Hides selected sprite
        selectedSprite.visible = NO;
        selectedSprite.position = self.childrenAnchorPointInPixels;
        [self addChild:selectedSprite z:1 tag:kSelectedSpriteTag];
        
        // Hides disabled sprite
        disabledSprite.visible = NO;
        disabledSprite.position = self.childrenAnchorPointInPixels;
        [self addChild:disabledSprite z:1 tag:kDisabledSpriteTag];
        
        if (highlightedSprite != nil) {
            // Hides highlighted sprite
            highlightedSprite.visible = NO;
            highlightedSprite.position = self.childrenAnchorPointInPixels;
            [self addChild:highlightedSprite z:1 tag:kHighlightedSpriteTag];
        }
        interiorDrag_ = YES;
    }
    
    return self;
}

#pragma mark Properties

- (void)setEnabled:(BOOL)enabled {
    if (enabled != enabled_) {
        enabled_ = enabled;
        // Makes sure button is unselected
        [self unselect];
        
        CCSprite *normalSprite = (CCSprite *)[self getChildByTag:kNormalSpriteTag];
        CCSprite *disabledSprite = (CCSprite *)[self getChildByTag:kDisabledSpriteTag];
        
        // Sets correct state
        if (!enabled) {
            state_ = CCControlStateDisabled;
        }
        else {
            state_ = CCControlStateNormal;
        }
        // Shows and hides the appropriate sprites
        normalSprite.visible = enabled;
        disabledSprite.visible = !enabled;
    }
}

#pragma mark Refactored public methods

// Shows selectedSprite & hides normalSprite
- (void)select {
    if (!self.selected) {
        CCSprite *normalSprite = (CCSprite *)[self getChildByTag:kNormalSpriteTag];
        CCSprite *selectedSprite = (CCSprite *)[self getChildByTag:kSelectedSpriteTag];
        self.selected = YES;
        state_ = CCControlStateSelected;
        selectedSprite.visible = YES;
        normalSprite.visible = NO;
    }
}

// Shows normalSprite & hides selectedSprite
- (void)unselect {
    if (self.selected) {
        CCSprite *normalSprite = (CCSprite *)[self getChildByTag:kNormalSpriteTag];
        CCSprite *selectedSprite = (CCSprite *)[self getChildByTag:kSelectedSpriteTag];
        self.selected = NO;
        state_ = CCControlStateNormal;
        normalSprite.visible = YES;
        selectedSprite.visible = NO;
    }
}

#pragma mark -
#pragma mark Touch Handling

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL retVal = NO;
    
    if (self.enabled && [self isTouchInside:touch]) {
        retVal = YES;
        interiorDrag_ = YES;
        [self select];
        [self sendActionsForControlEvents:CCControlEventTouchDown];
    }
    
    return retVal;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self isTouchInside:touch]) {
        [self select];
        if (interiorDrag_) {
            [self sendActionsForControlEvents:CCControlEventTouchDragInside];
        }
        else {
            interiorDrag_ = YES;
            [self sendActionsForControlEvents:CCControlEventTouchDragEnter];
        }
        
    }
    else {
        [self unselect];
        if (interiorDrag_) {
            interiorDrag_ = NO;
            [self sendActionsForControlEvents:CCControlEventTouchDragExit];
        }
        else {
            [self sendActionsForControlEvents:CCControlEventTouchDragOutside];
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self unselect];
    if ([self isTouchInside:touch]) {
        [self sendActionsForControlEvents:CCControlEventTouchUpInside];
    }
    else {
        [self sendActionsForControlEvents:CCControlEventTouchUpOutside];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self unselect];
    [self sendActionsForControlEvents:CCControlEventTouchCancel];
}

#endif

@end

@implementation NDControlButton (PrivateMethods)

- (CCSprite *)disabledSpriteForNormalSprite:(CCSprite *)normalSprite {
    // Duplicates normalSprite since no disabled sprite is provided.
    CCSprite *disabledSprite = [CCSprite spriteWithTexture:normalSprite.texture];
    // Dims disabledSprite
    disabledSprite.color = ccc3(150, 150, 150);
    return disabledSprite;
}

@end