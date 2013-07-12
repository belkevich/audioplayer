//
//  ABAppDelegate.m
//  ABAudioPlayerMac
//
//  Created by Alexey Belkevich on 7/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAppDelegate.h"
#import "ABWindowController.h"


@interface ABAppDelegate ()

@property (nonatomic, strong) NSWindowController *windowController;

@end


@implementation ABAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.windowController = [ABWindowController windowController];
    [self.windowController showWindow:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
