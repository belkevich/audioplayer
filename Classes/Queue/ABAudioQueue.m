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
#import "ABAudioQueueHelper.h"

const UInt32 kAudioQueueBufferCount = 3;

@interface ABAudioQueue ()
{
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffers[kAudioQueueBufferCount];
    __weak NSObject <ABAudioQueueDataSource> *_dataSource;
    ABAudioQueueHelper *_helper;
}
@end


@implementation ABAudioQueue

#pragma mark - life cycle

- (id)initWithAudioQueueDataSource:(NSObject <ABAudioQueueDataSource> *)aDataSource
{
    self = [super init];
    if (self)
    {
        _queue = NULL;
        _dataSource = aDataSource;
        _helper = [[ABAudioQueueHelper alloc] init];
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
    _queue = [ABAudioQueueBuilder audioQueueWithFormat:audioFormat
                                              callback:handleBufferCallback
                                                owner:self];
    if (_queue && [self audioQueueAllocateBufferWithSize:audioFormat.bufferSize])
    {
        [_helper setAudioQueueRef:_queue sampleRate:audioFormat.format->mSampleRate];
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
    if (_queue)
    {
        OSStatus status = AudioQueueStart(_queue, NULL);
        if (status == noErr)
        {
            return YES;
        }
        else
        {
            [self audioQueueStop];
        }
    }
    return NO;
}

- (void)audioQueuePause
{
    if (_queue)
    {
        AudioQueuePause(_queue);
    }
}

- (void)audioQueueStop
{
    if (_queue)
    {
        AudioQueueStop(_queue, false);
        AudioQueueDispose(_queue, true);
        _queue = NULL;
    }
    [_helper cleanAudioQueueHelper];
}

#pragma mark - properties

- (float)volume
{
    return _helper.volume;
}

- (void)setVolume:(float)volume
{
    _helper.volume = volume;
}

- (float)pan
{
    return _helper.pan;
}

- (void)setPan:(float)pan
{
    _helper.pan = pan;
}

@dynamic currentTime;

- (NSTimeInterval)currentTime
{
    return [_helper currentTime];
}

#pragma mark - private

- (BOOL)audioQueueAllocateBufferWithSize:(UInt32)bufferSize
{
    for (int i = 0; i < kAudioQueueBufferCount; i++)
    {
        OSStatus status = AudioQueueAllocateBuffer(_queue, bufferSize, &_buffers[i]);
        if (status != noErr || ![self audioQueueEnqueueBuffer:_buffers[i]])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)audioQueueEnqueueBuffer:(AudioQueueBufferRef)buffer
{
    ABAudioBuffer *currentBuffer = [_dataSource audioQueueCurrentBufferThreadSafely];
    [currentBuffer copyAudioDataToBuffer:buffer];
    if (currentBuffer && buffer->mAudioDataByteSize > 0)
    {
        OSStatus status = AudioQueueEnqueueBuffer(_queue, buffer,
                                                  currentBuffer.actualPacketsDescriptionCount,
                                                  currentBuffer.packetsDescription);
        switch (status)
        {
            case noErr:
                return YES;

            case kAudioQueueErr_EnqueueDuringReset:
                break;

            default:
                NSLog(@"Audio Queue failed to enqueue buffer with status %li", (long)status);
                [self audioQueueStop];
#if DEBUG
                @throw [NSException exceptionWithName:@"Audio Queue failed"
                                               reason:@"Audio Queue failed to enqueue buffer"
                                             userInfo:nil];
#else
                break;
#endif
        }
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
        if (![audioQueue audioQueueEnqueueBuffer:buffer])
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [audioQueue audioQueuePause];
            });
        }
    }
}

@end
