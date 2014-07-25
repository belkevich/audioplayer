//
//  ABAudioQueueHelper.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/24/14.
//  Copyright (c) 2014 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ABAudioQueueHelper : NSObject

- (id)initWithAudioQueueRef:(AudioQueueRef)queueRef sampleRate:(Float64)sampleRate;
- (void)updateVolume:(float)volume;
- (void)updatePan:(float)pan;
- (NSTimeInterval)currentTime;

@end
