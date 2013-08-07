//
//  ABAudioBuffer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioBuffer.h"

@interface ABAudioBuffer ()

@property (nonatomic, assign) void *audioData;
@property (nonatomic, assign) AudioStreamPacketDescription *packetsDescription;
@property (nonatomic, assign) UInt32 actualDataSize;
@property (nonatomic, assign) UInt32 actualPacketCount;
@property (nonatomic, assign) UInt32 expectedDataSize;
@property (nonatomic, assign) UInt32 expectedPacketCount;

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
        self.expectedDataSize = 0;
        self.expectedPacketCount = 0;
    }
    return self;
}

- (void)dealloc
{
    [self cleanAudioData];
    [self cleanAudioPacketsDescription];
}

#pragma mark - public

- (void)setExpectedDataSize:(UInt32)size packetCount:(UInt32)count
{
    if (self.expectedDataSize != size)
    {
        [self cleanAudioData];
        self.audioData = malloc(size);
        self.expectedDataSize = size;
    }
    if (self.expectedPacketCount != count)
    {
        [self cleanAudioPacketsDescription];
        self.packetsDescription = malloc(count * sizeof(AudioStreamPacketDescription));
        self.expectedPacketCount = count;
    }
}

- (void)setActualDataSize:(UInt32)size packetCount:(UInt32)count
{
    self.actualDataSize = size;
    self.actualPacketCount = count;
}

#pragma mark - properties

- (UInt32)actualPacketsSize
{
    return self.actualPacketCount * sizeof(AudioStreamPacketDescription);
}

#pragma mark - private

- (void)cleanAudioData
{
    if (self.audioData)
    {
        free(self.audioData);
        self.audioData = NULL;
    }
    self.expectedDataSize = 0;
    self.actualDataSize = 0;
}

- (void)cleanAudioPacketsDescription
{
    if (self.packetsDescription)
    {
        free(self.packetsDescription);
        self.packetsDescription = NULL;
    }
    self.expectedPacketCount = 0;
    self.actualPacketCount = 0;
}

@end
