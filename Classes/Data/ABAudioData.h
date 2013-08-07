//
//  ABAudioData.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABAudioBuffer;

@interface ABAudioData : NSObject
{
    dispatch_queue_t lockQueue;
    NSMutableArray *dataQueue;
    NSMutableArray *reuseQueue;
}

- (ABAudioBuffer *)popAudioBuffer;
- (void)pushAudioBuffer:(ABAudioBuffer *)buffer;
- (ABAudioBuffer *)reusableAudioBuffer;
- (void)reuseAudioBuffer:(ABAudioBuffer *)buffer;
- (void)purgeAudioData;

@end
