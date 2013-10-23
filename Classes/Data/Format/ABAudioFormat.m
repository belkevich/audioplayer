//
//  ABAudioFormat.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/8/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioFormat.h"
#import "ABAudioMagicCookie.h"

@implementation ABAudioFormat

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _format = malloc(sizeof(AudioStreamBasicDescription));
        _magicCookie = [[ABAudioMagicCookie alloc] init];
    }
    return self;
}

- (void)dealloc
{
    free(_format);
}

@end
