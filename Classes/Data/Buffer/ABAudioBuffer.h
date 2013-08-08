//
//  ABAudioBuffer.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ABAudioBuffer : NSObject

@property (nonatomic, readonly) void *audioData;
@property (nonatomic, readonly) AudioStreamPacketDescription *packetsDescription;
@property (nonatomic, readonly) UInt32 actualDataSize;
@property (nonatomic, readonly) UInt32 actualPacketCount;
@property (nonatomic, readonly) UInt32 actualPacketsSize;

- (void)setExpectedDataSize:(UInt32)size packetCount:(UInt32)count;
- (void)setActualDataSize:(UInt32)size packetCount:(UInt32)count;
- (void)copyAudioDataToBuffer:(AudioQueueBufferRef)buffer;

@end