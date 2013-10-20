//
//  ABSeekableFileReader.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 10/15/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABSeekableFileReader.h"
#import "ABAudioBuffer.h"
#import "ABAudioFormat.h"
#import "ABAudioMetadata.h"
#import "ABExtensionsHelper.h"
#import "ABSafeBlock.h"
#import "NSError+ABAudioFileReader.h"
#import "NSString+URL.h"
#import "ABTrim.h"

@interface ABSeekableFileReader ()

@property (nonatomic, assign) ABAudioReaderStatus audioReaderStatus;

@end


@implementation ABSeekableFileReader

@synthesize audioReaderStatus = _status, audioReaderFormat = _dataFormat;

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        audioFile = NULL;
        _dataFormat = [[ABAudioFormat alloc] init];
        self.audioReaderStatus = ABAudioReaderStatusEmpty;
    }
    return self;
}

- (void)dealloc
{
    [self audioReaderClose];
}

#pragma mark - audio reader protocol implementation

+ (BOOL)audioReaderCanOpenPath:(NSString *)path
{
    if (path.lastPathComponent)
    {
        NSArray *extensions = [ABExtensionsHelper nativeAudioExtensions];
        NSString *extension = path.pathExtension.lowercaseString;
        return ([extensions containsObject:extension] && !path.isURLString);
    }
    return NO;
}

- (void)audioReaderOpenPath:(NSString *)path success:(ABAudioReaderOpenSuccessBlock)successBlock
                    failure:(ABAudioReaderOpenFailureBlock)failureBlock
           metadataReceived:(ABAudioReaderMetadataReceivedBlock)metadataReceivedBlock
{
    [self audioReaderClose];
    if ([self audioFileOpen:path])
    {
        [self audioFileSetupDataFormat];
        [self audioFileCalculateBufferSize];
        [self audioFileCalculateDuration];
        ABSAFE_BLOCK(successBlock);
        ABAudioMetadata *metadata = [self audioFileMetadata];
        if (metadata)
        {
            ABSAFE_BLOCK(metadataReceivedBlock, metadata);
        }
    }
    else
    {
        ABSAFE_BLOCK(failureBlock, [NSError errorAudioFileOpenPath:path]);
    }
}

- (void)audioReaderClose
{
    if (audioFile)
    {
        AudioFileClose(audioFile);
        audioFile = NULL;
    }
    duration = 0.f;
    self.audioReaderStatus = ABAudioReaderStatusEmpty;
    if (extAudioFile)
    {
        ExtAudioFileDispose(extAudioFile);
        extAudioFile = NULL;
    }
}

- (ABAudioBuffer *)audioReaderCurrentBufferThreadSafely
{
    UInt32 readPackets = self.audioReaderFormat.packetsToRead;
    UInt32 readFrames = self.audioReaderFormat.dataFormat->mFramesPerPacket * readPackets;
    ABAudioBuffer *buffer = [[ABAudioBuffer alloc] init];
    [buffer setExpectedDataSize:self.audioReaderFormat.bufferSize];
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mNumberChannels = self.audioReaderFormat.dataFormat->mChannelsPerFrame;
    bufferList.mBuffers[0].mDataByteSize = self.audioReaderFormat.bufferSize;
    bufferList.mBuffers[0].mData = buffer.audioData;
    OSStatus status = ExtAudioFileRead(extAudioFile, &readFrames, &bufferList);
    if (status == noErr)
    {
        if (readFrames > 0)
        {
            buffer.actualDataSize = bufferList.mBuffers[0].mDataByteSize;
            self.audioReaderStatus = ABAudioReaderStatusOK;
            return buffer;
        }
        else
        {
            self.audioReaderStatus = ABAudioReaderStatusEnd;
        }
    }
    else
    {
        self.audioReaderStatus = ABAudioReaderStatusError;
    }
    return nil;
}

- (NSTimeInterval)audioReaderDuration
{
    return duration;
}

#pragma mark - private

- (BOOL)audioFileOpen:(NSString *)path
{
    NSURL *fileURL = [NSURL URLWithString:path];
    if (fileURL)
    {
        OSStatus status = AudioFileOpenURL((__bridge CFURLRef)fileURL, kAudioFileReadPermission, 0,
                                           &audioFile);
        if (status == noErr)
        {
            ExtAudioFileWrapAudioFileID(audioFile, false, &extAudioFile);
        }
        return (status == noErr);
    }
    return NO;
}

- (void)audioFileSetupDataFormat
{
    AudioStreamBasicDescription *audioFormat = self.audioReaderFormat.dataFormat;
    UInt32 dataFormatSize = sizeof(AudioStreamBasicDescription);
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &dataFormatSize, audioFormat);
    audioFormat->mFormatID = kAudioFormatLinearPCM;
    audioFormat->mFormatFlags = kAudioFormatFlagIsSignedInteger;
    audioFormat->mBitsPerChannel = 16;// sizeof(SInt16) * 8;
    audioFormat->mFramesPerPacket = 1;
    audioFormat->mBytesPerFrame = (audioFormat->mChannelsPerFrame * audioFormat->mBitsPerChannel)
                                  / 8;
    audioFormat->mBytesPerPacket = audioFormat->mFramesPerPacket * audioFormat->mBytesPerFrame;
    ExtAudioFileSetProperty(extAudioFile, kExtAudioFileProperty_ClientDataFormat,
                            sizeof(AudioStreamBasicDescription), audioFormat);
}

- (void)audioFileCalculateBufferSize
{
    UInt32 maxPacketSize = 0;
    UInt32 propertySize = sizeof(maxPacketSize);
    ExtAudioFileGetProperty(extAudioFile, kExtAudioFileProperty_ClientMaxPacketSize,
                            &propertySize, &maxPacketSize);
    AudioStreamBasicDescription *dataFormat = self.audioReaderFormat.dataFormat;
    if (dataFormat->mFramesPerPacket != 0)
    {
        Float64 packetsForTime = dataFormat->mSampleRate / dataFormat->mFramesPerPacket * 0.5;
        UInt32 bufferSize = (UInt32)(packetsForTime * maxPacketSize);
        self.audioReaderFormat.bufferSize = ABTRIM(bufferSize, 0x4000, 0x50000);
    }
    else
    {
        self.audioReaderFormat.bufferSize = MAX(0x50000, maxPacketSize);
    }
    self.audioReaderFormat.packetsToRead = self.audioReaderFormat.bufferSize / maxPacketSize;
}

- (void)audioFileCalculateDuration
{
    UInt32 size = sizeof(NSTimeInterval);
    OSStatus status = AudioFileGetProperty(audioFile, kAudioFilePropertyEstimatedDuration, &size,
                                           &duration);
    if (status != noErr)
    {
        duration = 0.f;
    }
}

- (ABAudioMetadata *)audioFileMetadata
{
    ABAudioMetadata *metadata = nil;
    CFDictionaryRef metadataDictionary = [self audioFileProperty:kAudioFilePropertyInfoDictionary];
    if (metadataDictionary)
    {
        NSDictionary *dictionary = (__bridge NSDictionary *)metadataDictionary;
        metadata = [[ABAudioMetadata alloc] initWithAudioFileMetadataDictionary:dictionary];
        CFRelease(metadataDictionary);
        CFDataRef artworkData = [self audioFileProperty:kAudioFilePropertyAlbumArtwork];
        if (artworkData)
        {
            [metadata artworkWithData:(__bridge NSData *)artworkData];
            CFRelease(artworkData);
        }
        [metadata id3TagsWithData:[self audioFileID3Data]];
    }
    return metadata;
}

- (NSData *)audioFileID3Data
{
    UInt32 size = 0;
    OSStatus status = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyID3Tag, &size, NULL);
    if (status == noErr && size > 0)
    {
        char *bytes = (char *)malloc(size);
        status = AudioFileGetProperty(audioFile, kAudioFilePropertyID3Tag, &size, bytes);
        if (status == noErr)
        {
            return [NSData dataWithBytesNoCopy:bytes length:size freeWhenDone:YES];
        }
        else
        {
            free(bytes);
        }
    }
    return nil;
}

- (void *)audioFileProperty:(AudioFilePropertyID)property
{
    if (audioFile)
    {
        UInt32 size = 0, writable = 0;
        OSStatus status = AudioFileGetPropertyInfo(audioFile, property, &size, &writable);
        if (status == noErr)
        {
            void *value = NULL;
            status = AudioFileGetProperty(audioFile, property, &size, &value);
            return status == noErr ? value : NULL;
        }
    }
    return NULL;
}

@end
