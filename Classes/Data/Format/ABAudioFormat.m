//
//  ABAudioFormat.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/8/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioFormat.h"
#import "ABAudioBuffer.h"

@interface ABAudioFormat ()

@property (nonatomic, assign) AudioStreamBasicDescription *dataFormat;
@property (nonatomic, assign) void *magicCookie;
@property (nonatomic, assign) UInt32 magicCookieSize;

@end


@implementation ABAudioFormat

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        self.dataFormat = malloc(sizeof(AudioStreamBasicDescription));
        self.magicCookie = NULL;
    }
    return self;
}

- (void)dealloc
{
    free(self.dataFormat);
    [self cleanMagicCookie];
}

#pragma mark - public

- (void)createMagicCookieWithSize:(UInt32)size
{
    [self cleanMagicCookie];
    if (size > 0)
    {
        self.magicCookie = malloc(size);
        self.magicCookieSize = size;
    }
}

#pragma mark - private

- (void)cleanMagicCookie
{
    if (self.magicCookie)
    {
        free(self.magicCookie);
    }
    self.magicCookieSize = 0;
}

@end
