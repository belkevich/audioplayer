//
//  ABAudioPlayer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/25/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioPlayer.h"
#import "ABAudioQueueDataSource.h"
#import "ABAudioUnitDelegate.h"
#import "ABAudioQueue.h"
#import "ABAudioUnitBuilder.h"
#import "ABAudioFileUnit.h"
#import "ABAudioBuffer.h"
#import "ABAudioFormat.h"
#import "ABAudioMetadata.h"
#import "NSError+ABAudioUnit.h"
#import "NSError+ABAudioQueue.h"
#import "NSError+ABAudioPlayer.h"
#import "macros_all.h"
#import "ABSeekableFileUnit.h"

@interface ABAudioPlayer () <ABAudioQueueDataSource, ABAudioUnitDelegate>
{
    ABAudioUnitBuilder *_audioUnitBuilder;
}
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
        _volume = 0.5f;
        _audioUnitBuilder = [[ABAudioUnitBuilder alloc] initWithAudioUnitDelegate:self];
#warning replace this workaround with some proper solution
        [_audioUnitBuilder addAudioUnitClass:ABAudioFileUnit.class];
    }
    return self;
}

#pragma mark - public

- (void)playerPlaySource:(NSString *)path
{
    [self playerStop];
    self.source = path;
    if (path)
    {
        _audioQueue = [[ABAudioQueue alloc] initWithAudioQueueDataSource:self];
        _audioUnit = [_audioUnitBuilder audioUnitForSource:path];
        if (self.audioUnit)
        {
            [self playerOpenAudioSource];
        }
        else
        {
            NSError *error = [NSError errorAudioPlayerNoAudioUnitForPath:self.source];
            [self playerFailWithError:error];
        }
    }
    else
    {
        [self playerFailWithError:[NSError errorAudioPlayerSourceEmpty]];
    }
}

- (void)playerStop
{
    [self.audioQueue audioQueueStop];
    [self.audioUnit audioUnitClose];
    self.status = ABAudioPlayerStatusStopped;
}

- (void)playerPause
{
    [self.audioQueue audioQueuePause];
    self.status = ABAudioPlayerStatusPaused;
}

- (void)playerResume
{
    if (self.status == ABAudioPlayerStatusPaused)
    {
        [self.audioQueue audioQueuePlay];
        self.status = ABAudioPlayerStatusPlaying;
    }
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
    _volume = range_value(volume, 0.f, 1.f);
    [self.audioQueue audioQueueSetVolume:_volume];
}

- (void)setPan:(float)pan
{
    _pan = range_value(pan, -1.f, 1.f);
    [self.audioQueue audioQueueSetPan:_pan];
}

- (NSTimeInterval)time
{
    return [self.audioQueue audioQueueTime];
}

- (NSTimeInterval)duration
{
    return [self.audioUnit audioUnitDuration];
}

#pragma mark - audio queue data source implementation

- (ABAudioBuffer *)audioQueueCurrentBufferThreadSafely
{
    ABAudioBuffer *buffer = [self.audioUnit audioUnitCurrentBuffer];
    if (!buffer)
    {
        __weak ABAudioPlayer *weakSelf = self;
        main_queue_block(^
        {
            switch (weakSelf.audioUnit.audioUnitStatus)
            {
                case ABAudioUnitStatusEmpty:
                    weakSelf.status = ABAudioPlayerStatusBuffering;
                    break;

                case ABAudioUnitStatusEnd:
                    [weakSelf.audioQueue audioQueueStop];
                    weakSelf.status = ABAudioPlayerStatusStopped;
                    break;

                case ABAudioUnitStatusError:
                    [weakSelf playerFailWithError:[NSError errorAudioUnitReadPackets]];
                    break;

                default:
                    break;
            }
        });
    }
    return buffer;
}

#pragma mark - audio unit delegate implementation

- (void)audioUnitDidOpen:(NSObject <ABAudioUnitProtocol> *)audioUnit
{
    if ([self.audioQueue audioQueueSetupFormat:audioUnit.audioUnitFormat])
    {
        if ([self.audioQueue audioQueuePlay])
        {
            [self.audioQueue audioQueueSetVolume:self.volume];
            [self.audioQueue audioQueueSetPan:self.pan];
            self.status = ABAudioPlayerStatusPlaying;
        }
        else
        {
            [self playerFailWithError:[NSError errorAudioQueuePlay]];
        }
    }
    else
    {
        [self playerFailWithError:[NSError errorAudioQueueSetup]];
    }
}

- (void)audioUnit:(NSObject <ABAudioUnitProtocol> *)audioUnit didFail:(NSError *)error
{
    [self playerFailWithError:error];
}

- (void) audioUnit:(NSObject <ABAudioUnitProtocol> *)audioUnit
didReceiveMetadata:(ABAudioMetadata *)metadata
{
    if ([self.delegate respondsToSelector:@selector(audioPlayer:didReceiveMetadata:)])
    {
        [self.delegate audioPlayer:self didReceiveMetadata:metadata];
    }
}

#pragma mark - private

- (void)playerOpenAudioSource
{
    self.status = ABAudioPlayerStatusBuffering;
    [self.audioUnit audioUnitOpenPath:self.source];
}

- (void)playerFailWithError:(NSError *)error
{
    [self.audioQueue audioQueueStop];
    self.status = ABAudioPlayerStatusError;
    [self.delegate audioPlayer:self didFail:error];
}

@end
