//
//  ABAudioMagicCookie.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 10/23/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABAudioMagicCookie : NSObject

@property (nonatomic, readonly) void *data;
@property (nonatomic, readonly) UInt32 size;
@property (nonatomic, readonly) BOOL isValid;

- (void)createMagicCookieWithSize:(UInt32)size;

@end
