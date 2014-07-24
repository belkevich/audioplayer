//
//  ABAudioQueueHelper.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/24/14.
//  Copyright (c) 2014 okolodev. All rights reserved.
//

#import "ABAudioQueueHelper.h"
#import "ABAudioQueueTime.h"
#import "macros_extra.h"

@interface ABAudioQueueHelper ()
{
    AudioQueueRef _queue;
    ABAudioQueueTime *_time;
}
@end

@implementation ABAudioQueueHelper

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _time = [[ABAudioQueueTime alloc] init];
        _volume = 0.5f;
        _pan = 0.f;
    }
    return self;
}

- (void)dealloc
{
    [self cleanAudioQueueHelper];
}

#pragma mark - public

- (void)setAudioQueueRef:(AudioQueueRef)queueRef sampleRate:(Float64)sampleRate
{
    _queue = queueRef;
    self.volume = _volume;
    self.pan = _pan;
    [_time setAudioQueueRef:queueRef sampleRate:sampleRate];
}

- (void)cleanAudioQueueHelper
{
    [_time cleanAudioQueueTime];
    _queue = NULL;
}

#pragma mark - properties

- (void)setPan:(float)pan
{
    _pan = range_value(pan, -1.f, 1.f);
    [self audioQueueSetParam:kAudioQueueParam_Pan value:_pan];

}

- (void)setVolume:(float)volume
{
    _volume = range_value(volume, 0.f, 1.f);
    [self audioQueueSetParam:kAudioQueueParam_Volume value:_volume];
}

@dynamic currentTime;

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
