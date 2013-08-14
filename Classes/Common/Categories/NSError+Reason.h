//
//  NSError+Reason.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/14/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Reason)

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code reason:(NSString *)reason;

@end
