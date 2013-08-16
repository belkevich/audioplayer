//
//  ABPlayerViewController.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABAudioPlayerDelegate.h"

@interface ABPlayerViewController : NSViewController <ABAudioPlayerDelegate>
{
    ABAudioPlayer *player;
}

@property (nonatomic, weak) IBOutlet NSTextField *timeField;
@property (nonatomic, strong) IBOutlet NSTextView *metadataText;
@property (nonatomic, weak) IBOutlet NSSlider *volumeSlider;
@property (nonatomic, weak) IBOutlet NSSlider *panSlider;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *activity;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)pauseButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;
- (IBAction)volumeValueChanged:(id)sender;
- (IBAction)panValueChanged:(id)sender;

@end
