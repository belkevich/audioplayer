//
//  ABAudioBuffer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioBuffer.h"
#import "macros_extra.h"

@implementation ABAudioBuffer

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _data = NULL;
        _packetsDescription = NULL;
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
        _data = safe_malloc(size);
        expectedDataSize = size;
    }
}

- (void)setExpectedPacketsDescriptionCount:(UInt32)count
{
    if (expectedPacketsDescriptionCount != count)
    {
        [self cleanAudioPacketsDescription];
        _packetsDescription = safe_malloc(count * sizeof(AudioStreamPacketDescription));
        expectedPacketsDescriptionCount = count;
    }
}

- (void)copyAudioDataToBuffer:(AudioQueueBufferRef)buffer
{
    if (self.data && self.actualDataSize > 0)
    {
        memcpy(buffer->mAudioData, self.data, self.actualDataSize);
        buffer->mAudioDataByteSize = self.actualDataSize;
    }
}

#pragma mark - private

- (void)cleanAudioData
{
    if (_data)
    {
        free(_data);
        _data = NULL;
    }
    expectedDataSize = 0;
    self.actualDataSize = 0;
}

- (void)cleanAudioPacketsDescription
{
    if (_packetsDescription)
    {
        free(_packetsDescription);
        _packetsDescription = NULL;
    }
    expectedPacketsDescriptionCount = 0;
    self.actualPacketsDescriptionCount = 0;
}

@end
