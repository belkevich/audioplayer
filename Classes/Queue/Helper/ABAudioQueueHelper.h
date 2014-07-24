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

@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float pan;
@property (nonatomic, readonly) NSTimeInterval currentTime;

- (void)setAudioQueueRef:(AudioQueueRef)queueRef sampleRate:(Float64)sampleRate;
- (void)cleanAudioQueueHelper;

@end
