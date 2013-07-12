//
//  NSWindowController+Controller.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSWindowController+Controller.h"

@implementation NSWindowController (Controller)

+ (instancetype)windowController
{
    return [[self alloc] initWithWindowNibName:NSStringFromClass([self class])];
}

@end
