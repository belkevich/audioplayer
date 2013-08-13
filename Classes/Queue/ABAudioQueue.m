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
#import "ABAudioTimeHelper.h"

@interface ABAudioQueue ()

@property (nonatomic, strong) ABAudioFormat *audioFormat;
@property (nonatomic, strong) ABAudioTimeHelper *audioTime;

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
        AudioStreamBasicDescription *format = self.audioFormat.dataFormat;
        self.audioTime = [[ABAudioTimeHelper alloc] initWithAudioQueue:queue format:format];
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
    self.audioTime = nil;
}

- (void)audioQueueVolume:(float)volume
{
    [self audioQueueSetParam:kAudioQueueParam_Volume value:volume];
}

- (void)audioQueuePan:(float)pan
{
    [self audioQueueSetParam:kAudioQueueParam_Pan value:pan];
}

- (NSTimeInterval)currentTime
{
    return [self.audioTime currentTime];
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
        OSStatus status = AudioQueueEnqueueBuffer(queue, buffer, currentBuffer.actualPacketCount,
                                                  currentBuffer.packetsDescription);
        switch (status)
        {
            case noErr:
                return YES;

            case kAudioQueueErr_EnqueueDuringReset:
                break;

            default:
                NSLog(@"Audio Queue failed to enqueue buffer with status %li", status);
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

- (void)audioQueueSetParam:(AudioQueueParameterID)param value:(AudioQueueParameterValue)value
{
    if (queue)
    {
        AudioQueueSetParameter(queue, param, value);
    }
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
