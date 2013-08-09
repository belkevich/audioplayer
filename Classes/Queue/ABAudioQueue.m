//
//  ABAudioQueue.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioQueue.h"
#import "ABAudioQueueBuilder.h"
#import "ABAudioFormat.h"
#import "ABAudioBuffer.h"

@interface ABAudioQueue ()

@property (nonatomic, strong) ABAudioFormat *audioFormat;

@end


@implementation ABAudioQueue

#pragma mark - life cycle

- (id)initWithAudioQueueDataSource:(NSObject <ABAudioQueueDataSource> *)aDataSource
{
    self = [super init];
    if (self)
    {
        queue = NULL;
        dataSource = aDataSource;
    }
    return self;
}

- (void)dealloc
{
    [self audioQueueStop];
}

#pragma mark - public

- (BOOL)audioQueueSetupFormat:(ABAudioFormat *)audioFormat
{
    [self audioQueueStop];
    self.audioFormat = audioFormat;
    queue = [ABAudioQueueBuilder audioQueueWithFormat:self.audioFormat callback:handleBufferCallback
                                                owner:self];
    if (queue && [self audioQueueAllocateBuffer])
    {
        return YES;
    }
    else
    {
        [self audioQueueStop];
        return NO;
    }
}

- (BOOL)audioQueuePlay
{
    if (queue)
    {
        OSStatus status = AudioQueueStart(queue, NULL);
        return (status == noErr);
    }
    return NO;
}

- (void)audioQueuePause
{
    if (queue)
    {
        AudioQueuePause(queue);
    }
}

- (void)audioQueueStop
{
    if (queue)
    {
        AudioQueueStop(queue, false);
        AudioQueueDispose(queue, true);
        queue = NULL;
    }
    self.audioFormat = nil;
}

#pragma mark - private

- (BOOL)audioQueueAllocateBuffer
{
    UInt32 bufferSize = self.audioFormat.bufferSize;
    for (int i = 0; i < kAudioQueueBufferCount; i++)
    {
        OSStatus status = AudioQueueAllocateBuffer(queue, bufferSize, &buffers[i]);
        if (status != noErr || ![self audioQueueEnqueueBuffer:buffers[i]])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)audioQueueEnqueueBuffer:(AudioQueueBufferRef)buffer
{
    ABAudioBuffer *currentBuffer = [dataSource audioQueueCurrentBufferThreadSafely];
    [currentBuffer copyAudioDataToBuffer:buffer];
    if (currentBuffer && buffer->mAudioDataByteSize > 0)
    {
#if DEBUG
        NSLog(@"%lu, %lu", currentBuffer.actualPacketCount, currentBuffer.actualDataSize);
#endif
        OSStatus status = AudioQueueEnqueueBuffer(queue, buffer, currentBuffer.actualPacketCount,
                                                  currentBuffer.packetsDescription);
        if (status != noErr)
        {
            NSLog(@"Audio Queue failed to enqueue buffer with status %li", status);
#if DEBUG
            @throw [NSException exceptionWithName:@"Audio Queue failed"
                                           reason:@"Audio Queue failed to enqueue buffer"
                                         userInfo:nil];
#endif
        }
        return (status == noErr);
    }
    return NO;
}

#pragma mark - callback

static void handleBufferCallback(void *instance, AudioQueueRef __unused queue,
                                 AudioQueueBufferRef buffer)
{
    ABAudioQueue *audioQueue = (__bridge ABAudioQueue *)instance;
    @autoreleasepool
    {
        [audioQueue audioQueueEnqueueBuffer:buffer];
    }
}

@end
