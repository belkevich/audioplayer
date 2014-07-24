//
//  ABAudioMagicCookie.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 10/23/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioMagicCookie.h"
#import "macros_extra.h"

@implementation ABAudioMagicCookie

#pragma mark - life cycle

- (void)dealloc
{
    [self cleanMagicCookie];
}

#pragma mark - public

- (void)createMagicCookieWithSize:(UInt32)size
{
    if (_size != size)
    {
        [self cleanMagicCookie];
        _size = size;
        _data = safe_malloc(size);
    }
}

#pragma mark - properties

- (BOOL)isValid
{
    return _data && _size;
}

#pragma mark - private

- (void)cleanMagicCookie
{
    if (_data)
    {
        free(_data);
        _data = NULL;
    }
}

@end
