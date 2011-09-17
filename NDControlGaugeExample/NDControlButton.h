/*
 * NDControlButton.h
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

#import "CCControl.h"

/*
 * @class
 * NDControlButton is a subclass of CCControl. This basic iOS button control 
 * allows the user to tap it to perform an action. It also generates all the  
 * transitional touch events.
 */
@interface NDControlButton : CCControl {
    /** Tags for accessing node's children. */
    enum {
        kNormalSpriteTag,
        kSelectedSpriteTag,
        kHighlightedSpriteTag,
        kDisabledSpriteTag,
    };
    /** Boolean flag for tracking drag proximity. */
    BOOL interiorDrag_;
}

#pragma mark Constructors

/** Creates button with normal sprite. 
 *
 * @see initWithNormalSprite:
 */
+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite;

/** Creates button with normal & disabled sprites.
 *
 * @see initWithNormalSprite:disabledSprite:
 */
+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite disabledSprite:(CCSprite *)disabledSprite;

/** Creates button with normal and selected sprites.
 *
 * @see initWithNormalSprite:selectedSprite:
 */
+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite;

/** Creates button with normal, selected and disabled sprites.
 *
 * @see initWithNormalSprite:selectedSprite:disabledSprite:
 */
+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite disabledSprite:(CCSprite *)disabledSprite;


/** Creates button with normal, selected and highlighted sprites.
 *
 * @see initWithNormalSprite:selectedSprite:highlightedSprite:
 */
+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite highlightedSprite:(CCSprite *)highlightedSprite;

/** Creates button with normal, selected, highlighted and disabled sprites.
 *
 * @see initWithNormalSprite:selectedSprite:highlightedSprite:disabledSprite:
 */
+ (id)buttonWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite highlightedSprite:(CCSprite *)highlightedSprite disabledSprite:(CCSprite *)disabledSprite;


/** Convenient init - takes only normal sprite as parameter; duplicates 
 * normal sprite to create disabled sprite and calls 
 * initWithNormalSprite:disabledSprite: internally.
 *
 * @see initWithNormalSprite:disabledSprite:
 */
- (id)initWithNormalSprite:(CCSprite *)normalSprite;

/** Convenient init - takes only normal and disabled sprites as parameters;
 * duplicates normal sprite to create selected sprite and calls 
 * initWithNormalSprite:selectedSprite:disabledSprite: internally.
 *
 * @see initWithNormalSprite:selectedSprite:disabledSprite:
 */
- (id)initWithNormalSprite:(CCSprite *)normalSprite disabledSprite:(CCSprite *)disabledSprite;

/** Convenient init - takes only normal and selected sprites as parameters;
 * duplicates normal sprite to create disabled sprite and calls 
 * initWithNormalSprite:selectedSprite:disabledSprite: internally.
 *
 * @see initWithNormalSprite:selectedSprite:disabledSprite:
 */
- (id)initWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite;
 
/** Convenient init - takes only normal, selected and disabled sprites as 
 * parameters; duplicates normal sprite to create highlighted sprite and calls 
 * initWithNormalSprite:selectedSprite:highlightedSprite:disabledSprite: 
 * internally.
 *
 * @see initWithNormalSprite:selectedSprite:highlightedSprite:disabledSprite: 
 */
- (id)initWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite disabledSprite:(CCSprite *)disabledSprite;

/** Convenient init - takes only normal, selected and highlighted sprites as 
 * parameters; calls 
 * initWithNormalSprite:selectedSprite:highlightedSprite:disabledSprite:
 * internally.
 *
 * @see initWithNormalSprite:selectedSprite:highlightedSprite:disabledSprite:
 */
- (id)initWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite highlightedSprite:(CCSprite *)highlightedSprite;

/** Designated init.
 *
 * @param normalSprite CCSprite that is used as button's normal-state graphics. 
 *
 * @param selectedSprite CCSprite that is used as button's selected-state
 * graphics.
 *
 * @param highlightedSprite CCSprite that is used as button's highlighted-state
 * graphics. It is put to use only when compiled for Mac.
 *
 * @param disabledSprite CCSprite that is used as button's disabled-state
 * graphics.
 */
- (id)initWithNormalSprite:(CCSprite *)normalSprite selectedSprite:(CCSprite *)selectedSprite highlightedSprite:(CCSprite *)highlightedSprite disabledSprite:(CCSprite *)disabledSprite;

#pragma mark Refactored public methods

/** Puts button in selected state. */
- (void)select;

/** Releases button from selected state. */
- (void)unselect;

@end
