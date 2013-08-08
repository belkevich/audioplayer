//
//  ABAudioFileReader.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioFileReader.h"
#import "ABAudioBuffer.h"
#import "ABAudioFormat.h"

UInt32 const maxBufferSize = 0x50000;
UInt32 const minBufferSize = 0x4000;

@implementation ABAudioFileReader

@synthesize audioReaderStatus = _status, audioReaderFormat = _dataFormat;

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        audioFile = NULL;
        _dataFormat = [[ABAudioFormat alloc] init];
        _status = ABAudioReaderStatusEmpty;
    }
    return self;
}

- (void)dealloc
{
    [self audioReaderClose];
}

#pragma mark - audio reader protocol implementation

- (BOOL)audioReaderOpen:(NSString *)path success:(ABAudioReaderOpenSuccessBlock)successBlock
{
    [self audioReaderClose];
    BOOL status = [self audioFileOpen:path];
    if (status)
    {
        [self audioFileGetDataFormat];
        [self audioFileGetMagicCookie];
        [self audioFileCalculateBufferSize];
        if (successBlock)
        {
            successBlock();
        }
        return YES;
    }
    return NO;

}

- (void)audioReaderClose
{
    if (audioFile)
    {
        AudioFileClose(audioFile);
        audioFile = NULL;
    }
    packetCount = 0;
}

- (ABAudioBuffer *)audioReaderCurrentBufferThreadSafely
{
    UInt32 readBytes = 0;
    UInt32 readPackets = self.audioReaderFormat.packetsToRead;
    ABAudioBuffer *buffer = [[ABAudioBuffer alloc] init];
    [buffer setExpectedDataSize:self.audioReaderFormat.bufferSize packetCount:readPackets];
    OSStatus status = AudioFileReadPackets(audioFile, false, &readBytes, buffer.packetsDescription,
                                           packetCount, &readPackets, buffer.audioData);
    switch (status)
    {
        case noErr:
            packetCount += readPackets;
            [buffer setActualDataSize:readBytes packetCount:readPackets];
            _status = ABAudioReaderStatusOK;
            return buffer;

        case kAudioFileEndOfFileError:
            _status = ABAudioReaderStatusEnd;
            break;

        default:
            _status = ABAudioReaderStatusError;
            break;
    }
    return nil;
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
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &dataFormatSize,
                         self.audioReaderFormat.dataFormat);
}

- (void)audioFileGetMagicCookie
{
    UInt32 cookieSize = 0;
    OSStatus status = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyMagicCookieData,
                                               &cookieSize, NULL);
    if (status == noErr && cookieSize > 0)
    {
        [self.audioReaderFormat createMagicCookieWithSize:cookieSize];
        AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &cookieSize,
                             self.audioReaderFormat.magicCookie);
    }
}

- (void)audioFileCalculateBufferSize
{
    UInt32 maxPacketSize = 0;
    UInt32 propertySize = sizeof(maxPacketSize);
    AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySize,
                         &maxPacketSize);
    AudioStreamBasicDescription *dataFormat = self.audioReaderFormat.dataFormat;
    if (dataFormat->mFramesPerPacket != 0)
    {
        Float64 numPacketsForTime = dataFormat->mSampleRate / dataFormat->mFramesPerPacket * 0.5;
        self.audioReaderFormat.bufferSize = (UInt32)(numPacketsForTime * maxPacketSize);
        self.audioReaderFormat.bufferSize = MIN(maxBufferSize, self.audioReaderFormat.bufferSize);
        self.audioReaderFormat.bufferSize = MAX(minBufferSize, self.audioReaderFormat.bufferSize);
    }
    else
    {
        self.audioReaderFormat.bufferSize = (UInt32)MAX(maxBufferSize, maxPacketSize);
    }
    self.audioReaderFormat.packetsToRead = self.audioReaderFormat.bufferSize / maxPacketSize;
}

@end
