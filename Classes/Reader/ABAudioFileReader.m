//
//  ABAudioFileReader.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioFileReader.h"

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
        packetDescription = NULL;
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
        [self audioFileAllocatePacketDescription];
        return YES;
    }
    return NO;
}

- (void)closeAudio
{
    [self audioFileClose];
    [self audioFileCleanPacketDescription];
    [self audioFileCleanMagicCookie];
}

#pragma mark - audio queue data source implementation

- (AudioStreamBasicDescription *)audioQueueDataFormat
{
    return &dataFormat;
}

- (UInt32)audioQueueBufferSize
{
    return bufferSize;
}

- (void)audioQueueMagicCookie:(char **)pMagicCookie size:(UInt32 *)size
{
    [self audioFileCleanMagicCookie];
    OSStatus status = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyMagicCookieData,
                                               &cookieSize, NULL);
    if (status == noErr)
    {
        magicCookie = malloc(cookieSize);
        AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &cookieSize,
                             magicCookie);
        *pMagicCookie = magicCookie;
        *size = cookieSize;
    }
}

- (void)audioQueueUpdateThreadSafelyBuffer:(AudioQueueBufferRef)buffer
                         packetDescription:(AudioStreamPacketDescription **)pPacketDescription
                               readPackets:(UInt32 *)readPackets
{
    UInt32 readBytes = 0;
    *readPackets = packetsToRead;
    OSStatus status = AudioFileReadPackets(audioFile, false, &readBytes, packetDescription,
                                           packetCount, readPackets, buffer->mAudioData);
    if (status == noErr)
    {
        packetCount += *readPackets;
        buffer->mAudioDataByteSize = readBytes;
        *pPacketDescription = packetDescription;
    }
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

- (void)audioFileAllocatePacketDescription
{
    if (packetsToRead > 0 && (dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0))
    {
        size_t size = packetsToRead * sizeof(AudioStreamPacketDescription);
        packetDescription = (AudioStreamPacketDescription *)malloc(size);
    }
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
}

- (void)audioFileCleanPacketDescription
{
    if (packetDescription)
    {
        free(packetDescription);
        packetDescription = NULL;
    }
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
    cookieSize = 0;
}

@end
