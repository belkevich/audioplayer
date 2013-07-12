//
//  ABPlayerViewController.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ABPlayerViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSTextField *timeField;
@property (nonatomic, weak) IBOutlet NSTextField *channelsField;
@property (nonatomic, weak) IBOutlet NSTextField *metadataField;
@property (nonatomic, weak) IBOutlet NSSlider *seekSlider;
@property (nonatomic, weak) IBOutlet NSSlider *volumeSlider;
@property (nonatomic, weak) IBOutlet NSSlider *panSlider;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)pauseButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;
- (IBAction)seekValueChanged:(id)sender;
- (IBAction)volumeValueChanged:(id)sender;
- (IBAction)panValueChanged:(id)sender;

@end
