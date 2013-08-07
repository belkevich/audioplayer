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
#import "ABAudioData.h"
#import "ABAudioBuffer.h"

@implementation ABAudioPlayer

#pragma mark - main routine

- (id)init
{
    self = [super init];
    if (self)
    {
        audioData = [[ABAudioData alloc] init];
    }
    return self;
}

#pragma mark - public

- (void)play
{
    audioFile = [[ABAudioFileReader alloc] init];
    [audioFile openAudio:@"/Users/alex/Music/01.mp3"];
    audioQueue = [[ABAudioQueue alloc] initWithAudioQueueDataSource:self delegate:self];
    [audioQueue audioQueueSetup];
    [audioQueue audioQueuePlay];
}

#pragma mark - audio queue data source implementation

- (void)audioQueueDataFormat:(AudioStreamBasicDescription *)dataFormat
                  bufferSize:(UInt32 *)bufferSize packetsToRead:(UInt32 *)packetsToRead
{
    *dataFormat = audioFile.audioReaderDataFormat;
    *bufferSize = audioFile.audioReaderBufferSize;
    *packetsToRead = [audioFile respondsToSelector:@selector(audioReaderPacketsToRead)] ?
                     audioFile.audioReaderPacketsToRead : 0;
}

- (void)audioQueueMagicCookie:(char **)pMagicCookie size:(UInt32 *)size
{
    if ([audioFile respondsToSelector:@selector(audioReaderMagicCookieSize)] &&
        [audioFile respondsToSelector:@selector(audioReaderMagicCookie)])
    {
        *size = audioFile.audioReaderMagicCookieSize;
        *pMagicCookie = audioFile.audioReaderMagicCookie;
    }
}

- (void)audioQueueUpdateThreadSafelyBuffer:(AudioQueueBufferRef)buffer
                        packetsDescription:(AudioStreamPacketDescription *)packetsDescription
                               readPackets:(UInt32 *)readPackets
{
    ABAudioBuffer *audioBuffer = [audioData reusableAudioBuffer];
    [audioFile audioReaderFillAudioBuffer:audioBuffer];
    memcpy(buffer->mAudioData, audioBuffer.audioData, audioBuffer.actualDataSize);
    buffer->mAudioDataByteSize = audioBuffer.actualDataSize;
    if (packetsDescription && audioBuffer.packetsDescription && audioBuffer.actualPacketCount > 0)
    {
        memcpy(packetsDescription, audioBuffer.packetsDescription, audioBuffer.actualPacketsSize);
        *readPackets = audioBuffer.actualPacketCount;
    }
    [audioData reuseAudioBuffer:audioBuffer];
}

#pragma mark - audio queue delegate implementation

- (void)audioQueueBufferEmpty
{
    NSLog(@"buffer empty");
}

@end
