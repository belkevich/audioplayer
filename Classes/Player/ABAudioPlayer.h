//
//  ABAudioPlayer.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/25/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioQueueDataSource.h"

@class ABAudioQueue;
@class ABAudioFileReader;

@interface ABAudioPlayer : NSObject <ABAudioQueueDataSource>
{
    ABAudioQueue *audioQueue;
    ABAudioFileReader *audioFile;
}

@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float pan;
@property (nonatomic, readonly) NSTimeInterval time;

- (void)play;

@end
