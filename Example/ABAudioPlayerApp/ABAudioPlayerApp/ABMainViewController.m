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
    NSLog(@"%s", _cmd);
}

- (IBAction)pauseButtonPressed:(id)sender
{
    NSLog(@"%s", _cmd);
}

- (IBAction)stopButtonPressed:(id)sender
{
    NSLog(@"%s", _cmd);
}

- (IBAction)seekValueChanged:(id)sender
{
    NSLog(@"%s", _cmd);
}

- (IBAction)volumeValueChanged:(id)sender
{
    NSLog(@"%s", _cmd);
}

- (IBAction)panValueChanged:(id)sender
{
    NSLog(@"%s", _cmd);
}


@end
