//
//  ABAudioTimeHelper.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioTimeHelper.h"

@implementation ABAudioTimeHelper

#pragma mark - life cycle

- (id)initWithAudioQueue:(AudioQueueRef)queueRef format:(AudioStreamBasicDescription *)format
{
    self = [super init];
    if (self)
    {
        if (queueRef && format)
        {
            queue = queueRef;
            [self createTimeLineForAudioQueue];
            sampleRate = format->mSampleRate;
        }
        else
        {
            timeLine = NULL;
            queue = NULL;
            sampleRate = 0.f;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cleanTimeLine];
}

#pragma mark - properties

- (NSTimeInterval)currentTime
{
    if (queue && timeLine)
    {
        AudioTimeStamp timeStamp;
        AudioQueueGetCurrentTime(queue, timeLine, &timeStamp, NULL);
        return (NSTimeInterval)timeStamp.mSampleTime / (NSTimeInterval)sampleRate;
    }
    return 0;
}

#pragma mark - private

- (void)createTimeLineForAudioQueue
{
    OSStatus status = AudioQueueCreateTimeline(queue, &timeLine);
    if (status != noErr)
    {
        [self cleanTimeLine];
    }
}

- (void)cleanTimeLine
{
    if (timeLine)
    {
        AudioQueueDisposeTimeline(queue, timeLine);
        timeLine = NULL;
    }
    queue = NULL;
}

@end
