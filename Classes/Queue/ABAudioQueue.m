//
//  ABAudioQueue.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioQueue.h"
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
    if ([self audioQueueNewOutput] && [self audioQueueAllocateBuffer] &&
        [self audioQueuePrepareBuffer])
    {
        [self audioQueueSetupMagicCookies];
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

- (BOOL)audioQueueNewOutput
{
    if (self.audioFormat)
    {
        OSStatus status = AudioQueueNewOutput(self.audioFormat.dataFormat, handleBufferCallback,
                                              (__bridge void *)(self), NULL, NULL, 0, &queue);
        return (status == noErr);
    }
    return NO;
}

- (BOOL)audioQueueAllocateBuffer
{
    UInt32 bufferSize = self.audioFormat.bufferSize;
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
    for (int i = 0; i < kAudioQueueBufferCount; i++)
    {
        if (![self audioQueueEnqueueBuffer:buffers[i]])
        {
            return NO;
        }
    }
    return YES;
}

- (void)audioQueueSetupMagicCookies
{
    if (self.audioFormat.magicCookie)
    {
        AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, self.audioFormat.magicCookie,
                              self.audioFormat.magicCookieSize);
    }
}

- (BOOL)audioQueueEnqueueBuffer:(AudioQueueBufferRef)buffer
{
    ABAudioBuffer *currentBuffer = [dataSource audioQueueCurrentBufferThreadSafely];
    [currentBuffer copyAudioDataToBuffer:buffer];
    if (currentBuffer && buffer->mAudioDataByteSize > 0)
    {
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
