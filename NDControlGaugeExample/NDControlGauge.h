/*
 * NDControlGauge.h
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

#import "CCControl.h"

/*
 * @class
 * NDControlGauge is a subclass of CCControl. This iOS gauge control supports
 * the horizontal orientation and allows the user to tap or drag the gauge 
 * to set the gauge level.
 */
@interface NDControlGauge : CCControl {
    /** Tags for accessing node's children. */
    enum {
        kFrameNormalSpriteTag,
        kFrameDisabledSpriteTag,
        kContentNormalSpriteTag,
        kContentDisabledSpriteTag,
    };
    
    float level_;
    // min & max x position offsets relative to gauge's center
    float minX_;
    float maxX_;
}

/** Current gauge level; 0.0f <= level <= 1.0f */
@property (nonatomic) float level;

#pragma mark Contructors

/** Creates gauge with frame's normal sprite and content's normal sprite. 
 *
 * @see initWithFrameNormalSprite:contentNormalSprite:
 */
+ (id)gaugeWithFrameNormalSprite:(CCSprite *)frameNormalSprite contentNormalSprite:(CCSprite *)contentNormalSprite;

/** Creates gauge with frame's normal and disabled sprites and content's 
 * normal and disabled sprites. 
 *
 * @see initWithFrameNormalSprite:frameDisabledSprite:contentNormalSprite:contentDisabledSprite:
 */
+ (id)gaugeWithFrameNormalSprite:(CCSprite *)frameNormalSprite frameDisabledSprite:(CCSprite *)frameDisabledSprite contentNormalSprite:(CCSprite *)contentNormalSprite contentDisabledSprite:(CCSprite *)contentDisabledSprite;

/** Convenient init - takes only frame's normal and content's normal sprite as
 * parameters; duplicates normal sprites to create disabled sprites and calls 
 * initWithFrameNormalSprite:frameDisabledSprite:tabButton: internally.
 *
 * @see initWithFrameNormalSprite:frameDisabledSprite:contentNormalSprite:contentDisabledSprite:
 */
- (id)initWithFrameNormalSprite:(CCSprite *)frameNormalSprite contentNormalSprite:(CCSprite *)contentNormalSprite;

/** Designated init.
 *
 * @param frameNormalSprite CCSprite that is used as gauge's normal frame 
 * graphics. 
 *
 * @param frameDisabledSprite CCSprite that is used as gauge's disabled frame 
 * graphics. 
 *
 * @param contentNormalSprite CCSprite that is used as gauge's normal content
 * graphics.
 *
 * @param contentDisabledSprite CCSprite that is used as gauge's disabled
 * content graphics.
 */
- (id)initWithFrameNormalSprite:(CCSprite *)frameNormalSprite frameDisabledSprite:(CCSprite *)frameDisabledSprite contentNormalSprite:(CCSprite *)contentNormalSprite contentDisabledSprite:(CCSprite *)contentDisabledSprite;

#pragma mark Public methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
/** Returns the [0,1] saturated gauge level given touch instance.
 *
 * @param touch UITouch that is passed from touch events.
 */
- (float)levelForTouch:(UITouch *)touch;
#endif

@end
