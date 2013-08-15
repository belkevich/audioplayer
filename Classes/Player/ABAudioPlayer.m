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
#import "ABAudioMetadata.h"
#import "Trim.h"
#import "NSError+ABAudioReader.h"
#import "NSError+ABAudioQueue.h"

@interface ABAudioPlayer ()

@property (nonatomic, strong) ABAudioQueue *audioQueue;
@property (nonatomic, strong) ABAudioFileReader *audioFile;
@property (nonatomic, assign) ABAudioPlayerStatus status;

@end

@implementation ABAudioPlayer

#pragma mark - life cycle

- (id)initWithAudioPlayerDelegate:(NSObject <ABAudioPlayerDelegate> *)delegate
{
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _volume = 0.5f;
        _pan = 0.f;
        self.audioQueue = [[ABAudioQueue alloc] initWithAudioQueueDataSource:self];
    }
    return self;
}

#pragma mark - public

- (void)playerStart
{
    if (self.status == ABAudioPlayerStatusStopped || self.status == ABAudioPlayerStatusError)
    {
        __weak ABAudioPlayer *weakSelf = self;
        self.audioFile = [[ABAudioFileReader alloc] init];
        self.status = ABAudioPlayerStatusBuffering;
        [self.audioFile audioReaderOpenPath:@"/Users/alex/Music/01.mp3" success:^
        {
            if ([weakSelf.audioQueue audioQueueSetupFormat:weakSelf.audioFile.audioReaderFormat])
            {
                [weakSelf.audioQueue audioQueueVolume:weakSelf.volume];
                [weakSelf.audioQueue audioQueuePan:weakSelf.pan];
#warning extract to another block (need to think about it)
                if ([weakSelf.audioQueue audioQueuePlay])
                {
                    weakSelf.status = ABAudioPlayerStatusPlaying;
                }
                else
                {
                    [weakSelf playerFailWithError:[NSError errorAudioQueuePlay]];
                }
            }
            else
            {
                [weakSelf playerFailWithError:[NSError errorAudioQueueSetup]];
            }
        }                           failure:^(NSError *error)
        {
            [weakSelf playerFailWithError:error];
        }                  metadataReceived:^(ABAudioMetadata *metadata)
        {
            [weakSelf.delegate audioPlayer:weakSelf didRecieveMetadata:metadata];
        }];
    }
    else if (self.status == ABAudioPlayerStatusPaused)
    {
        [self.audioQueue audioQueuePlay];
        self.status = ABAudioPlayerStatusPlaying;
    }
}

- (void)playerStop
{
    [self.audioQueue audioQueueStop];
    [self.audioFile audioReaderClose];
    self.status = ABAudioPlayerStatusStopped;
}

- (void)playerPause
{
    [self.audioQueue audioQueuePause];
    self.status = ABAudioPlayerStatusPaused;
}

#pragma mark - properties

- (void)setStatus:(ABAudioPlayerStatus)status
{
    if (_status != status)
    {
        _status = status;
        if (status != ABAudioPlayerStatusError)
        {
            [self.delegate audioPlayer:self didChangeStatus:status];
        }
    }
}

- (void)setVolume:(float)volume
{
    _volume = TRIM(volume, 0.f, 1.f);
    [self.audioQueue audioQueueVolume:_volume];
}

- (void)setPan:(float)pan
{
    _pan = TRIM(pan, -1.f, 1.f);
    [self.audioQueue audioQueuePan:_pan];
}

- (NSTimeInterval)time
{
    return [self.audioQueue currentTime];
}

- (NSTimeInterval)duration
{
    return [self.audioFile audioReaderDuration];
}

#pragma mark - audio queue data source implementation

- (ABAudioBuffer *)audioQueueCurrentBufferThreadSafely
{
    ABAudioBuffer *buffer = [self.audioFile audioReaderCurrentBufferThreadSafely];
    if (!buffer)
    {
        __weak ABAudioPlayer *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            switch (weakSelf.audioFile.audioReaderStatus)
            {
                case ABAudioReaderStatusEmpty:
                    weakSelf.status = ABAudioPlayerStatusBuffering;
                    break;

                case ABAudioReaderStatusEnd:
                    [weakSelf.audioQueue audioQueueStop];
                    weakSelf.status = ABAudioPlayerStatusStopped;
                    break;

                case ABAudioReaderStatusError:
                    [weakSelf playerFailWithError:[NSError errorAudioReaderReadPackets]];
                    break;

                default:
                    break;
            }
        });
    }
    return buffer;
}

#pragma mark - private

- (void)playerFailWithError:(NSError *)error
{
    [self.audioQueue audioQueueStop];
    self.status = ABAudioPlayerStatusError;
    [self.delegate audioPlayer:self didFail:error];
}

@end
