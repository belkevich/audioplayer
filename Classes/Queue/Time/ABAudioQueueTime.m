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

- (id)initWithAudioQueueRef:(AudioQueueRef)queueRef sampleRate:(Float64)sampleRate
{
    self = [super init];
    if (self)
    {
        _queue = queueRef;
        _sampleRate = sampleRate;
        AudioQueueCreateTimeline(_queue, &_timeLine);
    }
    return self;
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

@end
