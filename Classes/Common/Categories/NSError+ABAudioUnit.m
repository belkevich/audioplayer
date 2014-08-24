//
//  NSError+ABAudioUnit.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/13/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSError+ABAudioUnit.h"
#import "NSError+Reason.h"

@implementation NSError (ABAudioUnit)

+ (NSError *)errorAudioUnitReadPackets
{
    return [NSError errorWithDomain:@"ABAudioUnit" code:1100 reason:@"Failed to read packets"];
}

@end
