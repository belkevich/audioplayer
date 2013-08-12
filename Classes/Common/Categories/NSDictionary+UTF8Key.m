//
//  NSDictionary+UTF8Key.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSDictionary+UTF8Key.h"

@implementation NSDictionary (UTF8Key)

- (id)valueForUTF8Key:(void const *)key
{
    return [self valueForKey:[NSString stringWithUTF8String:key]];
}

@end
