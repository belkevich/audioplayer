//
//  ABAudioQueue.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioQueueDataSource.h"
#import "ABAudioQueueDelegate.h"

static const int kAudioQueueBufferCount = 3;

@interface ABAudioQueue : NSObject
{
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[kAudioQueueBufferCount];
    AudioStreamBasicDescription dataFormat;
    __weak NSObject <ABAudioQueueDataSource> *dataSource;
    __weak NSObject <ABAudioQueueDelegate> *delegate;
}

- (id)initWithAudioQueueDataSource:(NSObject <ABAudioQueueDataSource> *)aDataSource
                          delegate:(NSObject <ABAudioQueueDelegate> *)aDelegate;

- (BOOL)setupAudioQueue;
- (BOOL)playAudioQueue;
- (void)pauseAudioQueue;
- (void)stopAudioQueue;

@end
