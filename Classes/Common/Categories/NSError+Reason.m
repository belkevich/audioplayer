//
//  NSError+Reason.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/14/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "NSError+Reason.h"

@implementation NSError (Reason)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code reason:(NSString *)reason
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:reason
                                                         forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

@end
