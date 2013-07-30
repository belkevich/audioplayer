//
//  ABAudioQueue.m
//  ABAudioPlayer
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
    [self audioQueueStop];
}

#pragma mark - public

- (BOOL)audioQueueSetup
{
    [self audioQueueStop];
    AudioStreamBasicDescription dataFormat;
    UInt32 bufferSize = 0;
    [dataSource audioQueueDataFormat:&dataFormat bufferSize:&bufferSize];
    if ([self audioQueueNewOutput:&dataFormat] && [self audioQueueAllocateBuffer:bufferSize] &&
        [self audioQueuePrepareBuffer])
    {
        [self audioQueueSetupMagicCookie];
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
}

#pragma mark - private

- (BOOL)audioQueueNewOutput:(AudioStreamBasicDescription *)dataFormat
{
    if (dataFormat)
    {
        OSStatus status = AudioQueueNewOutput(dataFormat, handleBufferCallback,
                                              (__bridge void *)(self), NULL, NULL, 0, &queue);
        return (status == noErr);
    }
    return NO;
}

- (BOOL)audioQueueAllocateBuffer:(UInt32)bufferSize
{
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

- (void)audioQueueSetupMagicCookie
{
    char *magicCookie = NULL;
    UInt32 magicCookieSize = 0;
    [dataSource audioQueueMagicCookie:&magicCookie size:&magicCookieSize];
    if (magicCookie && magicCookieSize > 0)
    {
        AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, magicCookie, magicCookieSize);
    }
}

- (BOOL)audioQueueEnqueueBuffer:(AudioQueueBufferRef)buffer
{
    UInt32 readPackets = 0;
    AudioStreamPacketDescription *packetDescription = NULL;
    [dataSource audioQueueUpdateThreadSafelyBuffer:buffer packetDescription:&packetDescription
                                       readPackets:&readPackets];
    if (buffer->mAudioDataByteSize > 0)
    {
        OSStatus status = AudioQueueEnqueueBuffer(queue, buffer, readPackets, packetDescription);
        return (status == noErr);
    }
    return NO;
}

- (void)handleAudioQueueBuffer:(AudioQueueBufferRef)buffer
{
    // running in a background thread
    if (![self audioQueueEnqueueBuffer:buffer])
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
