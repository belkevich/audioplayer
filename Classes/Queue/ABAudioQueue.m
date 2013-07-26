//
//  ABAudioQueue.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <mm_malloc.h>
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
        packetDescription = NULL;
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
    [self audioQueueSetupDataFormatAndPacketDescription];
    if ([self audioQueueNewOutput] && [self audioQueueAllocateBuffer] &&
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
    if (packetDescription)
    {
        free(packetDescription);
        packetDescription = NULL;
    }
    bufferSize = 0;
    packetsToRead = 0;
}

#pragma mark - private

- (void)audioQueueSetupDataFormatAndPacketDescription
{
    [dataSource audioQueueDataFormat:&dataFormat bufferSize:&bufferSize
                       packetsToRead:&packetsToRead];
    if (packetsToRead > 0 && (dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0))
    {
        size_t size = packetsToRead * sizeof(AudioStreamPacketDescription);
        packetDescription = (AudioStreamPacketDescription *)malloc(size);
    }
}

- (BOOL)audioQueueNewOutput
{
    OSStatus status = AudioQueueNewOutput(&dataFormat, handleBufferCallback,
                                          (__bridge void *)(self), NULL, NULL, 0, &queue);
    return (status == noErr);
}

- (BOOL)audioQueueAllocateBuffer
{
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
        if (![self audioQueueEnqueueBuffer:buffers[i]])
        {
            return NO;
        }
    }
    return YES;
}

- (void)audioQueueSetupMagicCookie
{
    if ([dataSource respondsToSelector:@selector(audioQueueMagicCookieSize)])
    {
        UInt32 size = [dataSource audioQueueMagicCookieSize];
        if ([dataSource respondsToSelector:@selector(audioQueueMagicCookie:)])
        {
            char *magicCookie = (char *)malloc(size);
            [dataSource audioQueueMagicCookie:magicCookie];
            AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, magicCookie, size);
            free(magicCookie);
        }
    }
}

- (BOOL)audioQueueEnqueueBuffer:(AudioQueueBufferRef)buffer
{
    UInt32 readPackets = packetsToRead;
    [dataSource audioQueueUpdateThreadSafelyBuffer:buffer packetDescription:packetDescription
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
