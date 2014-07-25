//
//  NSError+ABAudioPlayer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/16/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSError+ABAudioPlayer.h"
#import "NSError+Reason.h"

NSString * const kABAudioPlayerErrorDomain = @"ABAudioPlayer";

@implementation NSError (ABAudioPlayer)

+ (NSError *)errorAudioPlayerSourceEmpty
{
    return [NSError errorWithDomain:kABAudioPlayerErrorDomain code:1300
                             reason:@"Audio player source is empty"];
}

+ (NSError *)errorAudioPlayerNoAudioUnitForPath:(NSString *)path
{
    NSString *reason = [NSString stringWithFormat:@"Audio player doesn't have audio unit for "
    "path:\n%@", path];
    return [NSError errorWithDomain:kABAudioPlayerErrorDomain code:1301 reason:reason];
}

@end
