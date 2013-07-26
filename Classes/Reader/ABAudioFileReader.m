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
    NSURL *fileURL = [NSURL URLWithString:path];
    if (fileURL)
    {
        OSStatus status = AudioFileOpenURL((__bridge CFURLRef)fileURL, kAudioFileReadPermission, 0,
                                           &audioFile);
        return (status == noErr);
    }
    return NO;
}

- (void)closeAudio
{
    if (audioFile)
    {
        AudioFileClose(audioFile);
        audioFile = NULL;
    }
    packetCount = 0;
}

#pragma mark - audio queue data source implementation

- (void)audioQueueDataFormat:(AudioStreamBasicDescription *)dataFormat
                  bufferSize:(UInt32 *)bufferSize packetsToRead:(UInt32 *)packetsToRead
{
    [self audioFileSetupDataFormat:dataFormat];
    UInt32 maxPacketSize = [self audioFileMaxPacketSize];
    *bufferSize = [self audioFileBufferSizeForAudioDataFormat:dataFormat maxPacketSize:0];
    *packetsToRead = *bufferSize / maxPacketSize;
}

- (void)audioQueueUpdateThreadSafelyBuffer:(AudioQueueBufferRef)buffer
                         packetDescription:(AudioStreamPacketDescription *)packetDescription
                               readPackets:(UInt32 *)readPackets
{
    UInt32 readBytes = 0;
    OSStatus status = AudioFileReadPackets(audioFile, false, &readBytes, packetDescription,
                                           packetCount, readPackets, buffer->mAudioData);
    if (status == noErr)
    {
        packetCount += *readPackets;
        buffer->mAudioDataByteSize = readBytes;
    }
}

#pragma mark - private

- (UInt32)audioFileMaxPacketSize
{
    UInt32 maxPacketSize = 0;
    UInt32 propertySize = sizeof(maxPacketSize);
    AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySize,
                         &maxPacketSize);
    return maxPacketSize;
}

- (void)audioFileSetupDataFormat:(AudioStreamBasicDescription *)dataFormat
{
    UInt32 dataFormatSize = sizeof(AudioStreamBasicDescription);
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &dataFormatSize, dataFormat);
}

- (UInt32)audioFileBufferSizeForAudioDataFormat:(AudioStreamBasicDescription *)dataFormat
                                  maxPacketSize:(UInt32)maxPacketSize
{
    UInt32 bufferByteSize = 0;
    if (dataFormat->mFramesPerPacket != 0)
    {
        Float64 numPacketsForTime = dataFormat->mSampleRate / dataFormat->mFramesPerPacket * 0.5;
        bufferByteSize = (UInt32)(numPacketsForTime * maxPacketSize);
        bufferByteSize = (UInt32)MIN(maxBufferSize, bufferByteSize);
        bufferByteSize = (UInt32)MAX(minBufferSize, bufferByteSize);
    }
    else
    {
        bufferByteSize = (UInt32)MAX(maxBufferSize, maxPacketSize);
    }
    return bufferByteSize;
}

@end
