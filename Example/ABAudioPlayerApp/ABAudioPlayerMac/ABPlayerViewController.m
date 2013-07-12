//
//  ABPlayerViewController.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABPlayerViewController.h"

@interface ABPlayerViewController ()

@end

@implementation ABPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

#pragma mark - actions

- (IBAction)playButtonPressed:(id)sender
{
    NSLog(@"%s", sel_getName(_cmd));
}

- (IBAction)pauseButtonPressed:(id)sender
{
    NSLog(@"%s", sel_getName(_cmd));
}

- (IBAction)stopButtonPressed:(id)sender
{
    NSLog(@"%s", sel_getName(_cmd));
}

- (IBAction)seekValueChanged:(id)sender
{
    NSSlider *slider = sender;
    NSLog(@"%s, value: %.3f", sel_getName(_cmd), slider.floatValue);
}

- (IBAction)volumeValueChanged:(id)sender
{
    NSSlider *slider = sender;
    NSLog(@"%s, value: %.3f", sel_getName(_cmd), slider.floatValue);
}

- (IBAction)panValueChanged:(id)sender
{
    NSSlider *slider = sender;
    NSLog(@"%s, value: %.3f", sel_getName(_cmd), slider.floatValue);
}

@end
