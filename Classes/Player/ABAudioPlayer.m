//
//  ABAudioPlayer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/25/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioPlayer.h"
#import "ABAudioQueue.h"
#import "ABAudioFileReader.h"
#import "ABAudioBuffer.h"
#import "ABAudioFormat.h"

@implementation ABAudioPlayer

#pragma mark - public

- (void)play
{
    audioFile = [[ABAudioFileReader alloc] init];
    [audioFile audioReaderOpen:@"/Users/alex/Music/01.mp3"];
    audioQueue = [[ABAudioQueue alloc] initWithAudioQueueDataSource:self];
    [audioQueue audioQueueSetupFormat:audioFile.audioReaderFormat];
    [audioQueue audioQueuePlay];
}

#pragma mark - audio queue data source implementation

- (ABAudioBuffer *)audioQueueCurrentBufferThreadSafely
{
    ABAudioBuffer *buffer = [audioFile audioReaderCurrentBufferThreadSafely];
    if (!buffer)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            switch (audioFile.audioReaderStatus)
            {
                case ABAudioReaderStatusEmpty:
                    [audioQueue audioQueuePause];
                    break;

                case ABAudioReaderStatusError:
                case ABAudioReaderStatusEnd:
                    [audioQueue audioQueueStop];
                    break;

                default:
                    break;
            }
        });
    }
    return buffer;
}

@end
