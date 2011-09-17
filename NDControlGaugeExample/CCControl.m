/*
 * CCControl.m
 *
 * Copyright 2011 Yannick Loriot.
 * http://yannickloriot.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Modified by Eric Yim on 29/08/2011.
 *
 */

#import "CCControl.h"

@interface CCControl ()
/** 
 * Table of correspondence between the CCControlEvents and their
 * associated target-actions pairs. For each CCButtonEvents a list of 
 * NSInvocation (which contains the target-action pair) is linked.
 */
@property (nonatomic, retain) NSMutableDictionary *dispatchTable;

/**
 * Adds a target and action for a particular event to an internal dispatch 
 * table.
 * The action message may optionnaly include the sender and the event as 
 * parameters, in that order.
 * When you call this method, target is not retained.
 *
 * @param target The target object—that is, the object to which the action 
 * message is sent. It cannot be nil. The target is not retained.
 * @param action A selector identifying an action message. It cannot be NULL.
 * @param controlEvent A control event for which the action message is sent.
 * See "CCControlEvent" for constants.
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent;

/**
 * Removes a target and action for a particular event from an internal dispatch
 * table.
 *
 * @param target The target object—that is, the object to which the action 
 * message is sent. Pass nil to remove all targets paired with action and the
 * specified control events.
 * @param action A selector identifying an action message. Pass NULL to remove
 * all action messages paired with target.
 * @param controlEvent A control event for which the action message is sent.
 * See "CCControlEvent" for constants.
 */
- (void)removeTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent;

/**
 * Returns an NSInvocation object able to construct messages using a given 
 * target-action pair. The invocation may optionnaly include the sender and
 * the event as parameters, in that order.
 *
 * @param target The target object.
 * @param action A selector identifying an action message.
 * @param controlEvent A control events for which the action message is sent.
 * See "CCControlEvent" for constants.
 *
 * @return an NSInvocation object able to construct messages using a given 
 * target-action pair.
 */
- (NSInvocation *)invocationWithTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent;

/**
 * Returns the NSInvocation list for the given control event. If the list does
 * not exist, it'll create an empty array before returning it.
 *
 * @param controlEvent A control events for which the action message is sent.
 * See "CCControlEvent" for constants.
 *
 * @return the NSInvocation list for the given control event.
 */
- (NSMutableArray *)dispatchListforControlEvent:(CCControlEvent)controlEvent;

@end

@implementation CCControl
@synthesize dispatchTable = dispatchTable_;
@synthesize state = state_;
@synthesize enabled = enabled_;
@synthesize selected = selected_;
@synthesize highlighted = highlighted_;
@synthesize childrenAnchorPointInPixels = childrenAnchorPointInPixels_;
@synthesize controlPriority = controlPriority_;

- (void)dealloc
{
    [dispatchTable_ release], dispatchTable_ = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Initialise instance variables
        state_ = CCControlStateNormal;
        
        enabled_ = YES;
        selected_ = NO;
        highlighted_ = NO;
        
        
        controlPriority_ = kCCMenuTouchPriority;
        anchorPoint_ = CGPointMake(0.5f, 0.5f);
        
        // Initialise the tables
        dispatchTable_ = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

// Piggyback the assignment of childrenAnchorPointInPixels_ on setContentSize: 
- (void)setContentSize:(CGSize)newSize {
    [super setContentSize:newSize];
    CGPoint oldChildrenAnchorPointInPixels = childrenAnchorPointInPixels_;
    childrenAnchorPointInPixels_ = CGPointMake(self.anchorPoint.x * newSize.width, self.anchorPoint.y * newSize.height);
    
    CGPoint diff = ccpSub(oldChildrenAnchorPointInPixels, childrenAnchorPointInPixels_);
    for (CCNode *child in self.children) {
        child.position = ccpSub(child.position, diff);
    }
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

// Add to touch dispatcher on enter
- (void)onEnter {
	[super onEnter];
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:controlPriority_ swallowsTouches:YES];
}

// Remove from touch dispatcher on exit
- (void)onExit {
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

#pragma mark Touch Handling

// To be overridden by subclasses
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSAssert(NO, @"Subclass forgot to override this method!");
    return NO;
}

#endif

#pragma mark -
#pragma mark CCControl Public Methods

- (void)sendActionsForControlEvents:(CCControlEvent)controlEvents
{
    // For each control events
    for (int i = 0; i < kControlEventTotalNumber; i++)
    {
        // If the given controlEvents bitmask contains the curent event
        if ((controlEvents & (1 << i)))
        {
            NSMutableArray *invocationList = [self dispatchListforControlEvent:(1 << i)];
            
            for (NSInvocation *invocation in invocationList)
            {
                [invocation invoke];
            }
        }
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(CCControlEvent)controlEvents
{
    // For each control events
    for (int i = 0; i < kControlEventTotalNumber; i++)
    {
        // If the given controlEvents bitmask contains the curent event
        if ((controlEvents & (1 << i)))
        {
            [self addTarget:target action:action forControlEvent:(1 << i)];
        }
    }
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(CCControlEvent)controlEvents
{
    // For each control events
    for (int i = 0; i < kControlEventTotalNumber; i++)
    {
        // If the given controlEvents bitmask contains the curent event
        if ((controlEvents & (1 << i)))
        {
            [self removeTarget:target action:action forControlEvent:(1 << i)];
        }
    }
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)isTouchInside:(UITouch *)touch
{
    CGRect nodeSpaceBoundingBox = CGRectMake(-0.5f * self.contentSize.width, -0.5f * self.contentSize.height, self.contentSize.width, self.contentSize.height);
    return CGRectContainsPoint(nodeSpaceBoundingBox, [self convertTouchToNodeSpaceAR:touch]);
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)isMouseInside:(NSEvent *)event
{
    CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];

    return CGRectContainsPoint([self boundingBox], location);
}

#endif

#pragma mark CCControl Private Methods

- (void)addTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent
{
    // Create the invocation object
    NSInvocation *invocation = [self invocationWithTarget:target action:action forControlEvent:controlEvent];
    
    // Add the invocation into the dispatch list for the given control event
    NSMutableArray *eventInvocationList = [self dispatchListforControlEvent:controlEvent];
    [eventInvocationList addObject:invocation];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent
{
    // Retrieve all invocations for the given control event
    NSMutableArray *eventInvocationList = [self dispatchListforControlEvent:controlEvent];

#if NS_BLOCKS_AVAILABLE
    NSPredicate *predicate = 
    [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings)
     {
         NSInvocation *evaluatedObject = object;
         
         if ((target == nil && action == NULL)
             || (target == nil && [evaluatedObject selector] == action)
             || (action == NULL && [evaluatedObject target] == target)
             || ([evaluatedObject target] == target && [evaluatedObject selector] == action))
         {
             return YES;
         } 

         return NO;
     }];
    
    // Define the invocation to remove for the given control event
    NSArray *removeObjectList = [eventInvocationList filteredArrayUsingPredicate:predicate];
#else
    NSMutableArray *removeObjectList = [NSMutableArray array];
    if (target == nil && action == NULL)
    {
        removeObjectList = eventInvocationList;
    } else
    {
        if (target)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"target == %@",target];
            removeObjectList = [NSMutableArray arrayWithArray:[eventInvocationList filteredArrayUsingPredicate:predicate]];
        } else
        {
            removeObjectList = [NSMutableArray arrayWithArray:eventInvocationList];
        }
        
        if (action != NULL)
        {
            NSMutableArray *tempObjectToKeep = [NSMutableArray array];
            for (NSInvocation *invocation in removeObjectList)
            {
                if ([invocation selector] != action)
                {
                    [tempObjectToKeep addObject:invocation];
                }
            }
            [removeObjectList removeObjectsInArray:tempObjectToKeep];
        }
    }
#endif
    
    // Remove the corresponding invocation objects
    [eventInvocationList removeObjectsInArray:removeObjectList];
}

- (NSInvocation *)invocationWithTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent
{
    NSAssert(target, @"The target cannot be nil");
    NSAssert(action != NULL, @"The action cannot be NULL");
    
    // Create the method signature for the invocation
    NSMethodSignature *sig = [target methodSignatureForSelector:action];
    NSAssert(sig, @"The given target does not implement the given action");
    
    // Create the invocation object
    // First and second corresponds respectively to target and action
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:target];
    [invocation setSelector:action];
    
    // If the selector accept the sender as third argument
    if ([sig numberOfArguments] >= 3)
    {
        [invocation setArgument:&self atIndex:2];
    }
    
    // If the selector accept the CCControlEvent as fourth argument
    if ([sig numberOfArguments] >= 4)
    {
        [invocation setArgument:&controlEvent atIndex:3];
    }
    
    return invocation;
}

- (NSMutableArray *)dispatchListforControlEvent:(CCControlEvent)controlEvent
{
    // Get the key for the given control event
    NSNumber *controlEventKey = [NSNumber numberWithUnsignedInteger:controlEvent];
    
    // Get the invocation list for the  dispatch table
    NSMutableArray *invocationList = [dispatchTable_ objectForKey:controlEventKey];
    
    // If the invocation list does not exist for the  dispatch table, we create it
    if (invocationList == nil)
    {
        invocationList = [NSMutableArray arrayWithCapacity:1];
        
        [dispatchTable_ setObject:invocationList forKey:controlEventKey];
    }
    
    return invocationList;
}

@end
