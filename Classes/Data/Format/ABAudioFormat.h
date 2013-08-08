//
//  ABAudioFormat.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/8/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ABAudioFormat : NSObject

@property (nonatomic, readonly) AudioStreamBasicDescription *dataFormat;
@property (nonatomic, assign) UInt32 bufferSize;
@property (nonatomic, assign) UInt32 packetsToRead;

@property (nonatomic, readonly) void *magicCookie;
@property (nonatomic, readonly) UInt32 magicCookieSize;

- (void)createMagicCookieWithSize:(UInt32)size;

@end
