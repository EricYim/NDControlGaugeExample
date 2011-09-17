/*
 * HelloWorldLayer.m
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


// Import the interfaces
#import "HelloWorldLayer.h"
#import "NDControlButton.h"
#import "NDControlGauge.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		gaugeTouchDownValue_ = 0;
        // Disables update-on-touch-up by default
        updateOnTouchUp_ = NO;
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"0.0" fontName:@"Marker Felt" fontSize:64];

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the top-center of the screen
		label.position =  ccp( size.width /2 , 0.8f * size.height );
		
		// add the label as a child to this Layer
		[self addChild: label z:1 tag:kLabelTag];
        
        // Creates the necessary sprites to make the guage
        CCSprite *frameNormal = [CCSprite spriteWithFile:@"gauge_frame.png"];
        CCSprite *contentNormal = [CCSprite spriteWithFile:@"gauge_content.png"];
        
        // Constructs the gauge
        NDControlGauge *gauge = [NDControlGauge gaugeWithFrameNormalSprite:frameNormal contentNormalSprite:contentNormal];
        // Positions the gauge
        gauge.position = ccp(0.5 * size.width, 100.0f);
        // Adds gauge to this layer
        [self addChild:gauge z:1 tag:kGaugeTag];
        
        // Sets up event handlers
        [gauge addTarget:self action:@selector(touchDown:) forControlEvents:CCControlEventTouchDown];
        [gauge addTarget:self action:@selector(touchCancel:) forControlEvents:CCControlEventTouchCancel];
        [gauge addTarget:self action:@selector(valueChanged:) forControlEvents:CCControlEventValueChanged];
        [gauge addTarget:self action:@selector(touchUpInside:) forControlEvents:CCControlEventTouchUpInside | CCControlEventTouchUpOutside];
        // NDControlGauge doesn't respond to the following events
        [gauge addTarget:self action:@selector(touchDragInside:) forControlEvents:CCControlEventTouchDragInside];
        [gauge addTarget:self action:@selector(touchDragOutside:) forControlEvents:CCControlEventTouchDragOutside];
        [gauge addTarget:self action:@selector(touchDragEnter:) forControlEvents:CCControlEventTouchDragEnter];
        [gauge addTarget:self action:@selector(touchDragExit:) forControlEvents:CCControlEventTouchDragExit];
        
        // Creates a button that toggles the gauge
        CCSprite *normal = [CCSprite spriteWithFile:@"Icon-Small.png"];
        NDControlButton *gaugeOnOffButton = [NDControlButton buttonWithNormalSprite:normal];
        gaugeOnOffButton.position = ccp(0.5 * size.width, 30.0f);
        [self addChild:gaugeOnOffButton z:1 tag:kOnOffButton];
        [gaugeOnOffButton addTarget:self action:@selector(touchUpInside:) forControlEvents:CCControlEventTouchUpInside];
	}
	return self;
}

#pragma mark Event Handlers

- (void)touchDown:(CCControl *)sender {
    // If updateOnTouchUp_, save starting position so that we may return
    // to original position if touch is cancelled
    if (updateOnTouchUp_) {
        NDControlGauge *gauge = (NDControlGauge *)sender;
        gaugeTouchDownValue_ = gauge.level;
    }
}

- (void)touchDragInside:(CCControl *)sender {
    CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kLabelTag];
    label.string = [NSString stringWithFormat:@"Drag inside."];
}

- (void)touchDragOutside:(CCControl *)sender {
    CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kLabelTag];
    label.string = [NSString stringWithFormat:@"Drag outside."];
}

- (void)touchDragEnter:(CCControl *)sender {
    CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kLabelTag];
    label.string = [NSString stringWithFormat:@"Drag enter."];
}

- (void)touchDragExit:(CCControl *)sender {
    CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kLabelTag];
    label.string = [NSString stringWithFormat:@"Drag exit."];
}

- (void)touchUpInside:(CCControl *)sender {
    // If sender's tag is kGaugeTag and updateOnTouchUp_, update label.string
    if (sender.tag == kGaugeTag) {
        if (updateOnTouchUp_) {
            NDControlGauge *gauge = (NDControlGauge *)sender;
            CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kLabelTag];
            label.string = [NSString stringWithFormat:@"%.2f", gauge.level];
        }
    }
    // Else if tag is kOnOffButton, toggle gauge
    else if (sender.tag == kOnOffButton) {
        NDControlGauge *gauge = (NDControlGauge *)[self getChildByTag:kGaugeTag];
        gauge.enabled = !gauge.enabled;
    }
}

- (void)touchUpOutside:(CCControl *)sender {
    CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kLabelTag];
    label.string = [NSString stringWithFormat:@"Touch up outside."];
}

- (void)touchCancel:(CCControl *)sender {
    // If updateOnTouchUp_, return to starting position
    if (updateOnTouchUp_) {
        NDControlGauge *gauge = (NDControlGauge *)sender;
        gauge.level = gaugeTouchDownValue_;
        CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kLabelTag];
        label.string = [NSString stringWithFormat:@"%.2f", gaugeTouchDownValue_];
    }
}

- (void)valueChanged:(CCControl *)sender {
    // If !updateOnTouchUp_, update label.string
    if (!updateOnTouchUp_) {
        NDControlGauge *gauge = (NDControlGauge *)sender;
        CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:kLabelTag];
        label.string = [NSString stringWithFormat:@"%.2f", gauge.level];
    }
}

@end
