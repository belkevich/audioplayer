//
//  NSError+ABAudioQueue.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/14/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSError+ABAudioQueue.h"
#import "NSError+Reason.h"

@implementation NSError (ABAudioQueue)

+ (NSError *)errorAudioQueueSetup
{
    return [NSError errorWithDomain:@"ABAudioQueue" code:1000
                             reason:@"Failed to setup audio queue"];
}

+ (NSError *)errorAudioQueuePlay
{
    return [NSError errorWithDomain:@"ABAudioQueue" code:1001
                             reason:@"Failed to play audio queue"];
}


@end
