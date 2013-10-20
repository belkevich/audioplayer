//
//  ABAudioBuffer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioBuffer.h"
#import "ABSafeMalloc.h"

@interface ABAudioBuffer ()

@property (nonatomic, assign) void *audioData;
@property (nonatomic, assign) AudioStreamPacketDescription *packetsDescription;

@end

@implementation ABAudioBuffer

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        self.audioData = NULL;
        self.packetsDescription = NULL;
    }
    return self;
}

- (void)dealloc
{
    [self cleanAudioData];
    [self cleanAudioPacketsDescription];
}

#pragma mark - public

- (void)setExpectedDataSize:(UInt32)size
{
    if (expectedDataSize != size)
    {
        [self cleanAudioData];
        self.audioData = ABSAFE_MALLOC(size);
        expectedDataSize = size;
    }
}

- (void)setExpectedPacketsDescriptionCount:(UInt32)count
{
    if (expectedPacketsDescriptionCount != count)
    {
        [self cleanAudioPacketsDescription];
        self.packetsDescription = ABSAFE_MALLOC(count * sizeof(AudioStreamPacketDescription));
        expectedPacketsDescriptionCount = count;
    }
}

- (void)copyAudioDataToBuffer:(AudioQueueBufferRef)buffer
{
    if (self.audioData)
    {
        memcpy(buffer->mAudioData, self.audioData, self.actualDataSize);
        buffer->mAudioDataByteSize = self.actualDataSize;
    }
}

#pragma mark - private

- (void)cleanAudioData
{
    if (self.audioData)
    {
        free(self.audioData);
        self.audioData = NULL;
    }
    expectedDataSize = 0;
    self.actualDataSize = 0;
}

- (void)cleanAudioPacketsDescription
{
    if (self.packetsDescription)
    {
        free(self.packetsDescription);
        self.packetsDescription = NULL;
    }
    expectedPacketsDescriptionCount = 0;
    self.actualPacketsDescriptionCount = 0;
}

@end
