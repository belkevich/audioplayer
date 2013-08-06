//
//  ABAudioBuffer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioBuffer.h"

@interface ABAudioBuffer ()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) AudioStreamPacketDescription *packetsDescription;
@property (nonatomic, assign) UInt32 packetCount;

@end

@implementation ABAudioBuffer

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        self.data = [[NSMutableData alloc] init];
        self.packetsDescription = NULL;
        self.packetCount = 0;
    }
    return self;
}

- (void)dealloc
{
    [self cleanAudioPacketsDescription];
}

#pragma mark - public

- (void)setDataSize:(UInt32)size packetCount:(UInt32)count
{
    self.data.length = size;
    if (self.packetCount != count)
    {
        [self cleanAudioPacketsDescription];
        self.packetCount = count;
        size_t packetsSize = count * sizeof(AudioStreamPacketDescription);
        self.packetsDescription = malloc(packetsSize);
    }
}

#pragma mark - private

- (void)cleanAudioPacketsDescription
{
    if (self.packetsDescription)
    {
        free(self.packetsDescription);
    }
    self.packetCount = 0;
}

@end
