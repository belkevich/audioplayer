//
//  ABAudioData.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioData.h"
#import "ABAudioBuffer.h"

@implementation ABAudioData

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString *name = [NSString stringWithFormat:@"%u.org.okolodev.audiodata", self.hash];
        lockQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], 0);
        dataQueue = [[NSMutableArray alloc] init];
        reuseQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    if (lockQueue)
    {
        dispatch_release(lockQueue);
    }
#endif
}

#pragma mark - public

- (ABAudioBuffer *)popAudioBuffer
{
    __block ABAudioBuffer *buffer = nil;
    __weak NSMutableArray *queue = dataQueue;
    dispatch_sync(lockQueue, ^
    {
        buffer = queue.count > 0 ? [queue objectAtIndex:0] : nil;
    });
    return buffer;
}

- (void)pushAudioBuffer:(ABAudioBuffer *)buffer
{
    __weak NSMutableArray *queue = dataQueue;
    dispatch_async(lockQueue, ^
    {
        [queue addObject:buffer];
    });
}

- (ABAudioBuffer *)reusableAudioBuffer
{
    __block ABAudioBuffer *buffer = nil;
    __weak NSMutableArray *queue = reuseQueue;
    dispatch_sync(lockQueue, ^
    {
        buffer = queue.count > 1 ? [queue objectAtIndex:0] : [[ABAudioBuffer alloc] init];
    });
    return buffer;
}

- (void)reuseAudioBuffer:(ABAudioBuffer *)buffer
{
    __weak NSMutableArray *queue = reuseQueue;
    dispatch_async(lockQueue, ^
    {
        [queue addObject:buffer];
    });
}

- (void)purgeAudioData
{
    dispatch_async(lockQueue, ^
    {
        [dataQueue removeAllObjects];
        [reuseQueue removeAllObjects];
    });
}

@end
