//
//  NSViewController+Controller.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSViewController+Controller.h"

@implementation NSViewController (Controller)

+ (instancetype)viewController
{
    return [[self alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end
