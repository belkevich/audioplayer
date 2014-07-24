//
//  ABAudioQueue.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ABAudioQueueDataSource.h"

@class ABAudioFormat;

@interface ABAudioQueue : NSObject

@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float pan;
@property (nonatomic, readonly) NSTimeInterval currentTime;

- (id)initWithAudioQueueDataSource:(NSObject <ABAudioQueueDataSource> *)aDataSource;
- (BOOL)audioQueueSetupFormat:(ABAudioFormat *)audioFormat;
- (BOOL)audioQueuePlay;
- (void)audioQueuePause;
- (void)audioQueueStop;

@end
