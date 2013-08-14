//
//  NSError+ABAudioReader.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/13/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSError+ABAudioReader.h"
#import "NSError+Reason.h"

@implementation NSError (ABAudioReader)

+ (NSError *)errorAudioReaderReadPackets
{
    return [NSError errorWithDomain:@"ABAudioReader" code:1100 reason:@"Failed to read packets"];
}

@end
