//
//  NSError+ABAudioFileReader.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/13/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSError+ABAudioFileReader.h"
#import "NSError+Reason.h"

@implementation NSError (ABAudioFileReader)

+ (NSError *)errorAudioFileOpenPath:(NSString *)path
{
    NSString *reason = [NSString stringWithFormat:@"Can't open audio file at path:\n%@", path];
    return [NSError errorWithDomain:@"ABAudioFileReader" code:1200 reason:reason];
}

@end
