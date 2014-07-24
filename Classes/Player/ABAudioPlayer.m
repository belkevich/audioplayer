//
//  ABAudioPlayer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/25/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioPlayer.h"
#import "ABAudioQueueDataSource.h"
#import "ABAudioQueue.h"
#import "ABAudioUnitBuilder.h"
#import "ABAudioFileReader.h"
#import "ABAudioBuffer.h"
#import "ABAudioFormat.h"
#import "ABAudioMetadata.h"
#import "NSError+ABAudioReader.h"
#import "NSError+ABAudioQueue.h"
#import "NSError+ABAudioPlayer.h"
#import "macros_all.h"

@interface ABAudioPlayer () <ABAudioQueueDataSource>
@property (nonatomic, readonly) ABAudioUnitBuilder *audioUnitBuilder;
@property (nonatomic, readonly) NSObject <ABAudioUnitProtocol> *audioUnit;
@property (nonatomic, readonly) ABAudioQueue *audioQueue;
@property (nonatomic, assign) ABAudioPlayerStatus status;
@property (nonatomic, strong) NSString *source;
@end

@implementation ABAudioPlayer

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _audioQueue = [[ABAudioQueue alloc] initWithAudioQueueDataSource:self];
        _audioUnitBuilder = [[ABAudioUnitBuilder alloc] init];
        [self.audioUnitBuilder addAudioUnitClass:ABAudioFileReader.class];
    }
    return self;
}

#pragma mark - public

- (void)playerPlaySource:(NSString *)path
{
    if (![self.source isEqualToString:path])
    {
        self.source = path;
        [self playerStop];
        if (path)
        {
            [self playerStart];
        }
    }
}

- (void)playerStart
{
    if (self.status == ABAudioPlayerStatusStopped || self.status == ABAudioPlayerStatusError)
    {
        if (!self.source)
        {
            [self playerFailWithError:[NSError errorAudioPlayerSourceEmpty]];
        }
        else
        {
            _audioUnit = [self.audioUnitBuilder audioUnitForSource:self.source];
            if (!self.audioUnit)
            {
                NSError *error = [NSError errorAudioPlayerNoAudioReaderForPath:self.source];
                [self playerFailWithError:error];
            }
            else
            {
                [self playerOpenAudioSource];
            }
        }
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
    [self.audioUnit audioReaderClose];
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

- (float)volume
{
    return self.audioQueue.volume;
}

- (void)setVolume:(float)volume
{
    self.audioQueue.volume = volume;
}

- (float)pan
{
    return self.audioQueue.pan;
}

- (void)setPan:(float)pan
{
    self.audioQueue.pan = pan;
}

- (NSTimeInterval)time
{
    return [self.audioQueue currentTime];
}

- (NSTimeInterval)duration
{
    return [self.audioUnit audioReaderDuration];
}

#pragma mark - audio queue data source implementation

- (ABAudioBuffer *)audioQueueCurrentBufferThreadSafely
{
    ABAudioBuffer *buffer = [self.audioUnit audioReaderCurrentBufferThreadSafely];
    if (!buffer)
    {
        __weak ABAudioPlayer *weakSelf = self;
        main_queue_block(^
        {
            switch (weakSelf.audioUnit.audioReaderStatus)
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

- (void)playerOpenAudioSource
{
    __weak ABAudioPlayer *weakSelf = self;
    self.status = ABAudioPlayerStatusBuffering;
    [self.audioUnit audioReaderOpenPath:self.source success:^
    {
        if ([weakSelf.audioQueue audioQueueSetupFormat:weakSelf.audioUnit.audioReaderFormat])
        {
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
        if ([weakSelf.delegate respondsToSelector:@selector(audioPlayer:didReceiveMetadata:)])
        {
            [weakSelf.delegate audioPlayer:weakSelf didReceiveMetadata:metadata];
        }
    }];
}

- (void)playerFailWithError:(NSError *)error
{
    [self.audioQueue audioQueueStop];
    self.status = ABAudioPlayerStatusError;
    [self.delegate audioPlayer:self didFail:error];
}

@end
