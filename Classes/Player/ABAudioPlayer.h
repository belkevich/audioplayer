//
//  ABAudioPlayer.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/25/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioQueueDataSource.h"
#import "ABAudioQueueDelegate.h"
#import "ABAudioReaderDelegate.h"

@class ABAudioQueue;
@class ABAudioFileReader;

@interface ABAudioPlayer : NSObject
<ABAudioQueueDataSource, ABAudioQueueDelegate, ABAudioReaderDelegate>
{
    ABAudioQueue *audioQueue;
    ABAudioFileReader *audioFile;
}

- (void)play;

@end
