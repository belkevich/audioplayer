//
//  ABAudioQueue.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioQueueDataSource.h"

@class ABAudioFormat;

@interface ABAudioQueue : NSObject

- (id)initWithAudioQueueDataSource:(NSObject <ABAudioQueueDataSource> *)aDataSource;
- (BOOL)audioQueueSetupFormat:(ABAudioFormat *)audioFormat;
- (BOOL)audioQueuePlay;
- (void)audioQueuePause;
- (void)audioQueueStop;
- (void)audioQueueSetVolume:(float)volume;
- (void)audioQueueSetPan:(float)pan;
- (NSTimeInterval)audioQueueTime;

@end
