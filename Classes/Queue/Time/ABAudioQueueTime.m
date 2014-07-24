//
//  ABAudioQueueTime.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioQueueTime.h"

@interface ABAudioQueueTime ()
{
    AudioQueueRef _queue;
    AudioQueueTimelineRef _timeLine;
    Float64 _sampleRate;
}
@end

@implementation ABAudioQueueTime

#pragma mark - life cycle

- (void)dealloc
{
    [self cleanAudioQueueTime];
}

#pragma mark - public

- (void)setAudioQueueRef:(AudioQueueRef)queueRef sampleRate:(Float64)sampleRate
{
    [self cleanAudioQueueTime];
    if (queueRef && sampleRate > 0)
    {
        _queue = queueRef;
        _sampleRate = sampleRate;
        [self createTimeLineForAudioQueue];
    }
}

- (void)cleanAudioQueueTime
{
    if (_timeLine)
    {
        AudioQueueDisposeTimeline(_queue, _timeLine);
        _timeLine = NULL;
    }
    _queue = NULL;
    _sampleRate = 0.f;
}

#pragma mark - properties

- (NSTimeInterval)currentTime
{
    if (_queue && _timeLine)
    {
        AudioTimeStamp timeStamp;
        AudioQueueGetCurrentTime(_queue, _timeLine, &timeStamp, NULL);
        return (NSTimeInterval)timeStamp.mSampleTime / (NSTimeInterval)_sampleRate;
    }
    return 0;
}

#pragma mark - private

- (void)createTimeLineForAudioQueue
{
    OSStatus status = AudioQueueCreateTimeline(_queue, &_timeLine);
    if (status != noErr)
    {
        [self cleanAudioQueueTime];
    }
}

@end
