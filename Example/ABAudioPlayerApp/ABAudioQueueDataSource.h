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

- (void)audioQueueDataFormat:(AudioStreamBasicDescription *)dataFormat
                  bufferSize:(UInt32 *)bufferSize;
- (void)audioQueueMagicCookie:(char **)pMagicCookie size:(UInt32 *)size;
- (void)audioQueueUpdateThreadSafelyBuffer:(AudioQueueBufferRef)buffer
                         packetDescription:(AudioStreamPacketDescription **)pPacketDescription
                               readPackets:(UInt32 *)readPackets;

@end
