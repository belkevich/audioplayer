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

- (void)play;

@end
