//
//  ABAudioTimeHelper.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ABAudioTimeHelper : NSObject
{
    AudioQueueTimelineRef timeLine;
    AudioQueueRef queue;
    Float64 sampleRate;
}

@property (nonatomic, readonly) NSTimeInterval currentTime;

- (id)initWithAudioQueue:(AudioQueueRef)queueRef format:(AudioStreamBasicDescription *)format;

@end
