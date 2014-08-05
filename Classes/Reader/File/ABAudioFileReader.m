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
#import "ABAudioMetadata.h"
#import "ABAudioMagicCookie.h"
#import "ABExtensionsHelper.h"
#import "NSError+ABAudioFileReader.h"
#import "NSString+URL.h"
#import "macros_all.h"

UInt32 const audioFileMaxBuffer = 0x50000;
UInt32 const audioFileMinBuffer = 0x4000;

@implementation ABAudioFileReader

@synthesize audioUnitStatus = _status, audioUnitFormat = _dataFormat;

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        audioFile = NULL;
        _dataFormat = [[ABAudioFormat alloc] init];
        _status = ABAudioUnitStatusEmpty;
    }
    return self;
}

- (void)dealloc
{
    [self audioUnitClose];
}

#pragma mark - audio reader protocol implementation

+ (BOOL)audioUnitCanOpenPath:(NSString *)path
{
    if (path.lastPathComponent)
    {
        NSArray *extensions = [ABExtensionsHelper nativeAudioExtensions];
        NSString *extension = path.pathExtension.lowercaseString;
        return ([extensions containsObject:extension] && !path.isURLString);
    }
    return NO;
}

- (void)audioUnitOpenPath:(NSString *)path success:(ABAudioReaderOpenSuccessBlock)successBlock
                  failure:(ABAudioReaderOpenFailureBlock)failureBlock
         metadataReceived:(ABAudioReaderMetadataReceivedBlock)metadataReceivedBlock
{
    [self audioUnitClose];
    if ([self audioFileOpen:path])
    {
        [self audioFileGetDataFormat];
        [self audioFileGetMagicCookie];
        [self audioFileCalculateBufferSize];
        [self audioFileCalculateDuration];
        safe_block(successBlock);
        ABAudioMetadata *metadata = [self audioFileMetadata];
        if (metadata)
        {
            safe_block(metadataReceivedBlock, metadata);
        }
    }
    else
    {
        safe_block(failureBlock, [NSError errorAudioFileOpenPath:path]);
    }
}

- (void)audioUnitClose
{
    if (audioFile)
    {
        AudioFileClose(audioFile);
        audioFile = NULL;
    }
    currentPacket = 0;
    duration = 0.f;
    _status = ABAudioUnitStatusEmpty;
}

- (ABAudioBuffer *)audioUnitCurrentBufferThreadSafely
{
    UInt32 readBytes = 0;
    UInt32 readPackets = self.audioUnitFormat.packetsToRead;
    ABAudioBuffer *buffer = [[ABAudioBuffer alloc] init];
    [buffer setExpectedDataSize:self.audioUnitFormat.bufferSize];
    [buffer setExpectedPacketsDescriptionCount:readPackets];
    OSStatus status = AudioFileReadPackets(audioFile, false, &readBytes, buffer.packetsDescription,
                                           currentPacket, &readPackets, buffer.data);
    switch (status)
    {
        case noErr:
            currentPacket += readPackets;
            buffer.actualDataSize = readBytes;
            buffer.actualPacketsDescriptionCount = readPackets;
            _status = ABAudioUnitStatusOK;
            return buffer;

        case kAudioFileEndOfFileError:
            _status = ABAudioUnitStatusEnd;
            break;

        default:
            _status = ABAudioUnitStatusError;
            break;
    }
    return nil;
}

- (NSTimeInterval)audioUnitDuration
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
        return (status == noErr);
    }
    return NO;
}

- (void)audioFileGetDataFormat
{
    UInt32 dataFormatSize = sizeof(AudioStreamBasicDescription);
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &dataFormatSize,
                         self.audioUnitFormat.format);
}

- (void)audioFileGetMagicCookie
{
    UInt32 cookieSize = 0;
    OSStatus status = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyMagicCookieData,
                                               &cookieSize, NULL);
    if (status == noErr && cookieSize > 0)
    {
        [self.audioUnitFormat.magicCookie createMagicCookieWithSize:cookieSize];
        AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &cookieSize,
                             self.audioUnitFormat.magicCookie.data);
    }
}

- (void)audioFileCalculateBufferSize
{
    UInt32 maxPacketSize = 0;
    UInt32 propertySize = sizeof(maxPacketSize);
    AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySize,
                         &maxPacketSize);
    AudioStreamBasicDescription *dataFormat = self.audioUnitFormat.format;
    if (dataFormat->mFramesPerPacket != 0)
    {
        Float64 packetsForTime = dataFormat->mSampleRate / dataFormat->mFramesPerPacket * 0.5;
        UInt32 bufferSize = (UInt32)(packetsForTime * maxPacketSize);
        self.audioUnitFormat.bufferSize = range_value(bufferSize, audioFileMinBuffer, audioFileMaxBuffer);
    }
    else
    {
        self.audioUnitFormat.bufferSize = MAX(audioFileMaxBuffer, maxPacketSize);
    }
    self.audioUnitFormat.packetsToRead = self.audioUnitFormat.bufferSize / maxPacketSize;
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
        return metadata;
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
