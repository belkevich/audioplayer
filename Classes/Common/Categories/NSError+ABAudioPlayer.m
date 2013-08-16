//
//  NSError+ABAudioPlayer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/16/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSError+ABAudioPlayer.h"
#import "NSError+Reason.h"

@implementation NSError (ABAudioPlayer)

+ (NSError *)errorAudioPlayerSourceEmpty
{
    return [NSError errorWithDomain:@"ABAudioPlayer" code:1300
                             reason:@"Audio player source is empty"];
}

@end
