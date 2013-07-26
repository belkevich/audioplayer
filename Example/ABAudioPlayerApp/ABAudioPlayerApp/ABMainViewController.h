//
//  ABMainViewController.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/11/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABAudioPlayer;

@interface ABMainViewController : UIViewController
{
    ABAudioPlayer *player;
}

@property (nonatomic, weak) IBOutlet UITextField *timeField;
@property (nonatomic, weak) IBOutlet UITextField *channelsField;
@property (nonatomic, weak) IBOutlet UITextField *metadataField;
@property (nonatomic, weak) IBOutlet UISlider *seekSlider;
@property (nonatomic, weak) IBOutlet UISlider *volumeSlider;
@property (nonatomic, weak) IBOutlet UISlider *panSlider;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)pauseButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;
- (IBAction)seekValueChanged:(id)sender;
- (IBAction)volumeValueChanged:(id)sender;
- (IBAction)panValueChanged:(id)sender;

@end
