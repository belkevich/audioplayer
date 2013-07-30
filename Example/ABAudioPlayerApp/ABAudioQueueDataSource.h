//
//  ABAudioQueueDataSource.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol ABAudioQueueDataSource <NSObject>

- (AudioStreamBasicDescription *)audioQueueDataFormat;
- (UInt32)audioQueueBufferSize;
- (void)audioQueueUpdateThreadSafelyBuffer:(AudioQueueBufferRef)buffer
                         packetDescription:(AudioStreamPacketDescription **)pPacketDescription
                               readPackets:(UInt32 *)readPackets;

@optional

- (UInt32)audioQueueMagicCookieSize;
- (void)audioQueueMagicCookie:(char *)magicCookie;

@end
