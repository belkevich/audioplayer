//
//  ABAudioQueueTime.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ABAudioQueueTime : NSObject

- (id)initWithAudioQueueRef:(AudioQueueRef)queueRef sampleRate:(Float64)sampleRate;
- (NSTimeInterval)currentTime;

@end
