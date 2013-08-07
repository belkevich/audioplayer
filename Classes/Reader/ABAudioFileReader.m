//
//  ABAudioFileReader.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioFileReader.h"
#import "ABAudioBuffer.h"

@implementation ABAudioFileReader

UInt32 const maxBufferSize = 0x50000;
UInt32 const minBufferSize = 0x4000;

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        audioFile = NULL;
        magicCookie = NULL;
    }
    return self;
}

- (void)dealloc
{
    [self closeAudio];
}

#pragma mark - public

- (BOOL)openAudio:(NSString *)path
{
    [self closeAudio];
    BOOL status = [self audioFileOpen:path];
    if (status)
    {
        [self audioFileGetDataFormat];
        [self audioFileCalculateBufferSize];
        return YES;
    }
    return NO;
}

- (void)closeAudio
{
    [self audioFileClose];
    [self audioFileCleanMagicCookie];
}

#pragma mark - audio reader protocol implementation

- (AudioStreamBasicDescription)audioReaderDataFormat
{
    return dataFormat;
}

- (UInt32)audioReaderBufferSize
{
    return bufferSize;
}

- (void)audioReaderFillAudioBuffer:(ABAudioBuffer *)buffer
{
    UInt32 readBytes = 0;
    UInt32 readPackets = packetsToRead;
    [buffer setExpectedDataSize:bufferSize packetCount:packetsToRead];
    OSStatus status = AudioFileReadPackets(audioFile, false, &readBytes, buffer.packetsDescription,
                                           packetCount, &readPackets, buffer.audioData);
    if (status == noErr)
    {
        packetCount += readPackets;
        [buffer setActualDataSize:readBytes packetCount:readPackets];
    }
}

- (UInt32)audioReaderPacketsToRead
{
    return packetsToRead;
}

- (UInt32)audioReaderMagicCookieSize
{
    UInt32 cookieSize = 0;
    OSStatus status = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyMagicCookieData,
                                               &cookieSize, NULL);
    return status == noErr ? cookieSize : 0;
}

- (char *)audioReaderMagicCookie
{
    [self audioFileCleanMagicCookie];
    UInt32 cookieSize = [self audioReaderMagicCookieSize];
    if (cookieSize > 0)
    {
        magicCookie = malloc(cookieSize);
        AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &cookieSize,
                             magicCookie);
    }
    return magicCookie;
}

#pragma mark - private

- (BOOL)audioFileOpen:(NSString *)path
{
    NSURL *fileURL = [NSURL URLWithString:path];
    if (fileURL)
    {
        OSStatus status = AudioFileOpenURL((__bridge CFURLRef)fileURL, kAudioFileReadPermission, 0,
                                           &audioFile);
        return (status == noErr);
    }
    return NO;
}

- (void)audioFileGetDataFormat
{
    UInt32 dataFormatSize = sizeof(AudioStreamBasicDescription);
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &dataFormatSize, &dataFormat);
}

- (void)audioFileCalculateBufferSize
{
    UInt32 maxPacketSize = 0;
    UInt32 propertySize = sizeof(maxPacketSize);
    AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySize,
                         &maxPacketSize);
    if (dataFormat.mFramesPerPacket != 0)
    {
        Float64 numPacketsForTime = dataFormat.mSampleRate / dataFormat.mFramesPerPacket * 0.5;
        bufferSize = (UInt32)(numPacketsForTime * maxPacketSize);
        bufferSize = (UInt32)MIN(maxBufferSize, bufferSize);
        bufferSize = (UInt32)MAX(minBufferSize, bufferSize);
    }
    else
    {
        bufferSize = (UInt32)MAX(maxBufferSize, maxPacketSize);
    }
    packetsToRead = bufferSize / maxPacketSize;
}

- (void)audioFileClose
{
    if (audioFile)
    {
        AudioFileClose(audioFile);
        audioFile = NULL;
    }
    bufferSize = 0;
    packetsToRead = 0;
    packetCount = 0;
}

- (void)audioFileCleanMagicCookie
{
    if (magicCookie)
    {
        free(magicCookie);
        magicCookie = NULL;
    }
}

@end
