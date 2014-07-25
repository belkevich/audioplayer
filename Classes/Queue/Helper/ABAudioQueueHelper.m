//
//  ABAudioQueueHelper.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/24/14.
//  Copyright (c) 2014 okolodev. All rights reserved.
//

#import "ABAudioQueueHelper.h"
#import "ABAudioQueueTime.h"

@interface ABAudioQueueHelper ()
{
    AudioQueueRef _queue;
    ABAudioQueueTime *_time;
}
@end

@implementation ABAudioQueueHelper

#pragma mark - life cycle

- (id)initWithAudioQueueRef:(AudioQueueRef)queueRef sampleRate:(Float64)sampleRate
{
    self = [super init];
    if (self)
    {
        _queue = queueRef;
        _time = [[ABAudioQueueTime alloc] initWithAudioQueueRef:queueRef sampleRate:sampleRate];
    }
    return self;
}

#pragma mark - public

- (void)updateVolume:(float)volume
{
    [self audioQueueSetParam:kAudioQueueParam_Volume value:volume];
}

- (void)updatePan:(float)pan
{
    [self audioQueueSetParam:kAudioQueueParam_Pan value:pan];
}

- (NSTimeInterval)currentTime
{
    return _time.currentTime;
}

#pragma mark - private

- (void)audioQueueSetParam:(AudioQueueParameterID)param value:(AudioQueueParameterValue)value
{
    if (_queue)
    {
        AudioQueueSetParameter(_queue, param, value);
    }
}

@end
