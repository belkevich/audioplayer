//
//  ABAudioQueue.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioQueueDataSource.h"
#import "ABAudioQueueDelegate.h"


static const UInt32 kAudioQueueBufferCount = 3;

@interface ABAudioQueue : NSObject
{
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[kAudioQueueBufferCount];
    AudioStreamPacketDescription *packetsDescription;
    __weak NSObject <ABAudioQueueDataSource> *dataSource;
    __weak NSObject <ABAudioQueueDelegate> *delegate;
}

- (id)initWithAudioQueueDataSource:(NSObject <ABAudioQueueDataSource> *)aDataSource
                          delegate:(NSObject <ABAudioQueueDelegate> *)aDelegate;

- (BOOL)audioQueueSetup;
- (BOOL)audioQueuePlay;
- (void)audioQueuePause;
- (void)audioQueueStop;

@end
