//
//  ABAudioPlayer.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/25/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioQueueDelegate.h"

@class ABAudioQueue;
@class ABAudioFileReader;

@interface ABAudioPlayer : NSObject <ABAudioQueueDelegate>
{
    ABAudioQueue *audioQueue;
    ABAudioFileReader *audioFile;
}

- (void)play;

@end
