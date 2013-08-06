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

@property (nonatomic, readonly) NSMutableData *data;
@property (nonatomic, readonly) AudioStreamPacketDescription *packetsDescription;
@property (nonatomic, readonly) UInt32 packetCount;

- (void)setDataSize:(UInt32)size packetCount:(UInt32)count;

@end