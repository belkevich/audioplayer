//
//  NSString+TimeInterval.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSString+TimeInterval.h"

@implementation NSString (TimeInterval)

+ (NSString *)stringWithTimeInterval:(NSTimeInterval)timeInterval
{
    if (timeInterval > 0.f)
    {
        unsigned int time = (unsigned int)round(timeInterval);
        unsigned int hours = time / 3600;
        unsigned int minutes = (time % 3600) / 60;
        unsigned int seconds = time % 60;
        return hours > 0 ? [NSString stringWithFormat:@"%u:%.2u:%.2u", hours, minutes, seconds] :
               [NSString stringWithFormat:@"%.2u:%.2u", minutes, seconds];
    }
    return @"0";
}

@end
