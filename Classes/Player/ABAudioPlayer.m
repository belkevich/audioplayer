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
#import "Trim.h"
#import "ABAudioMetadata.h"

@implementation ABAudioPlayer

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _volume = 0.5f;
        _pan = 0.f;
    }
    return self;
}

#pragma mark - public

- (void)play
{
    audioQueue = [[ABAudioQueue alloc] initWithAudioQueueDataSource:self];
    audioFile = [[ABAudioFileReader alloc] init];
    [audioFile audioReaderOpen:@"/Users/alex/Music/01.mp3" success:^
    {
        [audioQueue audioQueueSetupFormat:audioFile.audioReaderFormat];
        [audioQueue audioQueuePlay];
        [audioQueue audioQueueVolume:_volume];
        [audioQueue audioQueuePan:_pan];
    }];
}

- (void)stop
{
}

#pragma mark - properties

- (void)setVolume:(float)volume
{
    _volume = TRIM(volume, 0.f, 1.f);
    [audioQueue audioQueueVolume:_volume];
}

- (void)setPan:(float)pan
{
    _pan = TRIM(pan, -1.f, 1.f);
    [audioQueue audioQueuePan:_pan];
}

- (NSTimeInterval)time
{
    return [audioQueue currentTime];
}

- (NSTimeInterval)duration
{
    return [audioFile audioReaderDuration];
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
