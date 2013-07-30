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

@implementation ABAudioPlayer

#pragma mark - main routine

- (id)init
{
    self = [super init];
    if (self)
    {
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
                  bufferSize:(UInt32 *)bufferSize
{
    *dataFormat = audioFile.audioReaderDataFormat;
    *bufferSize = audioFile.audioReaderBufferSize;
}

- (void)audioQueueMagicCookie:(char **)pMagicCookie size:(UInt32 *)size
{
    *size = audioFile.audioReaderMagicCookieSize;
    *pMagicCookie = audioFile.audioReaderMagicCookie;
}

- (void)audioQueueUpdateThreadSafelyBuffer:(AudioQueueBufferRef)buffer
                         packetDescription:(AudioStreamPacketDescription **)pPacketDescription
                               readPackets:(UInt32 *)readPackets
{
    [audioFile audioReaderFillBuffer:buffer packetDescription:pPacketDescription
                         readPackets:readPackets];
}

#pragma mark - audio queue delegate implementation

- (void)audioQueueBufferEmpty
{
    NSLog(@"buffer empty");
}

@end
