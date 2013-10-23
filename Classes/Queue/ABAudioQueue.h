//
//  ABAudioQueue.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ABAudioQueueDataSource.h"

static const UInt32 kAudioQueueBufferCount = 3;

@class ABAudioFormat;

@interface ABAudioQueue : NSObject
{
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[kAudioQueueBufferCount];
    __weak NSObject <ABAudioQueueDataSource> *dataSource;
}

- (id)initWithAudioQueueDataSource:(NSObject <ABAudioQueueDataSource> *)aDataSource;
- (BOOL)audioQueueSetupFormat:(ABAudioFormat *)audioFormat;
- (BOOL)audioQueuePlay;
- (void)audioQueuePause;
- (void)audioQueueStop;
- (void)audioQueueVolume:(float)volume;
- (void)audioQueuePan:(float)pan;
- (NSTimeInterval)currentTime;

@end
