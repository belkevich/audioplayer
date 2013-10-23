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
{
    UInt32 expectedDataSize;
    UInt32 expectedPacketsDescriptionCount;
}

@property (nonatomic, readonly) void *data;
@property (nonatomic, readonly) AudioStreamPacketDescription *packetsDescription;
@property (nonatomic, assign) UInt32 actualDataSize;
@property (nonatomic, assign) UInt32 actualPacketsDescriptionCount;

- (void)setExpectedDataSize:(UInt32)size;
- (void)setExpectedPacketsDescriptionCount:(UInt32)count;
- (void)copyAudioDataToBuffer:(AudioQueueBufferRef)buffer;

@end