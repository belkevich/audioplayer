//
//  ABMainViewController.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/11/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABMainViewController.h"


@implementation ABMainViewController

#pragma mark - main routine

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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
    NSLog(@"%p", _cmd);
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
    NSLog(@"%p, value: %.1f", _cmd, slider.value);
}

- (IBAction)panValueChanged:(id)sender
{
    UISlider *slider = sender;
    NSLog(@"%p, value: %.1f", _cmd, slider.value);
}

@end
