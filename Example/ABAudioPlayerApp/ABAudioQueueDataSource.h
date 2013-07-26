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
                  bufferSize:(UInt32 *)bufferSize packetsToRead:(UInt32 *)readPackets;
- (void)audioQueueUpdateThreadSafelyBuffer:(AudioQueueBufferRef)buffer
                         packetDescription:(AudioStreamPacketDescription *)packetDescription
                               readPackets:(UInt32 *)readPackets;

@end
