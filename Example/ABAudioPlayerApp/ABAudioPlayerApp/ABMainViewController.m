//
//  ABMainViewController.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/11/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABMainViewController.h"
#import "ABAudioPlayer.h"

@interface ABMainViewController ()

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ABMainViewController

#pragma mark - main routine

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        player = [[ABAudioPlayer alloc] init];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self
                                                    selector:@selector(updatePlayedTime:)
                                                    userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - appearance

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - actions

- (IBAction)playButtonPressed:(id)sender
{
    [player play];
}

- (IBAction)pauseButtonPressed:(id)sender
{
    NSLog(@"%p", _cmd);
}

- (IBAction)stopButtonPressed:(id)sender
{
    NSLog(@"%p", _cmd);
}

- (IBAction)seekValueChanged:(id)sender
{
    UISlider *slider = sender;
    NSLog(@"%p, value: %.1f", _cmd, slider.value);
}

- (IBAction)volumeValueChanged:(id)sender
{
    UISlider *slider = sender;
    player.volume = slider.value;
}

- (IBAction)panValueChanged:(id)sender
{
    UISlider *slider = sender;
    player.pan = slider.value;
}

#pragma mark - private

- (void)updatePlayedTime:(id)sender
{
    NSUInteger time = (NSUInteger)player.time;
    NSUInteger hours = time / 3600;
    NSUInteger minutes = (time % 3600) / 60;
    NSUInteger seconds  = time % 60;
    self.timeField.text = [NSString stringWithFormat:@"%u:%.2u:%.2u", hours, minutes, seconds];
}

@end
