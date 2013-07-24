//
//  ABAudioQueue.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioQueue.h"

@implementation ABAudioQueue

#pragma mark - life cycle

- (id)initWithAudioQueueDataSource:(NSObject <ABAudioQueueDataSource> *)aDataSource
                          delegate:(NSObject <ABAudioQueueDelegate> *)aDelegate
{
    self = [super init];
    if (self)
    {
        queue = NULL;
        dataSource = aDataSource;
        delegate = aDelegate;
    }
    return self;
}

- (void)dealloc
{
    [self stopAudioQueue];
}

#pragma mark - public

- (BOOL)setupAudioQueue
{
    [dataSource audioQueueSetupDataFormat:&dataFormat];
    if ([self audioQueueNewOutput] && [self audioQueueAllocateBuffer] &&
        [self audioQueuePrepareBuffer])
    {
        return YES;
    }
    else
    {
        [self stopAudioQueue];
        return NO;
    }
}

- (BOOL)playAudioQueue
{
    OSStatus status = AudioQueueStart(queue, NULL);
    return (status == noErr);
}

- (void)pauseAudioQueue
{
    AudioQueuePause(queue);
}

- (void)stopAudioQueue
{
    AudioQueueStop(queue, false);
    AudioQueueDispose(queue, true);
    queue = NULL;
}

#pragma mark - private

- (BOOL)audioQueueNewOutput
{
    OSStatus status = AudioQueueNewOutput(&dataFormat, handleBufferCallback,
                                          (__bridge void *)(self), NULL, NULL, 0, &queue);
    return (status == noErr);
}

- (BOOL)audioQueueAllocateBuffer
{
    Float64 packetsPerTime = dataFormat.mSampleRate / dataFormat.mFramesPerPacket;
    UInt32 bufferSize = (UInt32)(packetsPerTime * dataFormat.mBytesPerPacket);
#ifdef DEBUG
    NSLog(@"Audio queue buffer size %lu", (unsigned long)bufferSize);
#endif
    for (int i = 0; i < kAudioQueueBufferCount; i++)
    {
        OSStatus status = AudioQueueAllocateBuffer(queue, bufferSize, &buffers[i]);
        if (status != noErr)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)audioQueuePrepareBuffer
{
    for (NSUInteger i = 0; i < kAudioQueueBufferCount; i++)
    {
        if (![self fillAudioQueueBuffer:buffers[i]])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)fillAudioQueueBuffer:(AudioQueueBufferRef)buffer
{
    [dataSource audioQueueFillBuffer:buffer];
    if (buffer->mAudioDataByteSize > 0)
    {
        OSStatus status = AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
        return (status == noErr);
    }
    return NO;
}

- (void)handleAudioQueueBuffer:(AudioQueueBufferRef)buffer
{
    // running in a background thread
    if (![self fillAudioQueueBuffer:buffer])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [delegate audioQueueBufferEmpty];
        });
    }
}

#pragma mark - callback

static void handleBufferCallback(void *instance, AudioQueueRef __unused queue,
                                 AudioQueueBufferRef buffer)
{
    ABAudioQueue *audioQueue = (__bridge ABAudioQueue *)instance;
    [audioQueue handleAudioQueueBuffer:buffer];
}

@end
