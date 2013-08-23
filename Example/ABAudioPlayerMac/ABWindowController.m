//
//  ABWindowController.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABWindowController.h"
#import "ABPlayerViewController.h"


@interface ABWindowController ()

@property (nonatomic, strong) NSViewController *controller;

@end


@implementation ABWindowController

#pragma mark - appearance

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.controller = [ABPlayerViewController viewController];
    [self.view addSubview:self.controller.view];
    
}

@end
