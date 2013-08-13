//
//  ABAudioPlayerDelegate.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/13/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ABAudioPlayerStatusStopped = 0,
    ABAudioPlayerStatusBuffering = 1,
    ABAudioPlayerStatusPlaying = 2,
    ABAudioPlayerStatusPaused = 3,
    ABAudioPlayerStatusError = 4
} ABAudioPlayerStatus;

@class ABAudioPlayer;
@class ABAudioMetadata;

@protocol ABAudioPlayerDelegate <NSObject>

- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didChangeStatus:(ABAudioPlayerStatus)status;
- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didFail:(NSError *)error;
- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didRecieveMetadata:(ABAudioMetadata *)metadata;

@end
