//
//  NSString+URL.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/23/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)

- (BOOL)isURLString
{
    NSRange range = [self rangeOfString:@"://"];
    return range.location != NSNotFound;
}

@end
