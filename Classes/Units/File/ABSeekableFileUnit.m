//
//  ABSeekableFileUnit.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 10/15/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABSeekableFileUnit.h"
#import "ABAudioBuffer.h"
#import "ABAudioFormat.h"
#import "ABAudioMetadata.h"
#import "ABExtensionsHelper.h"
#import "NSError+ABAudioFileUnit.h"
#import "NSString+URL.h"
#import "macros_all.h"

@interface ABSeekableFileUnit ()
{
    ExtAudioFileRef _extAudioFile;
    AudioFileID _audioFile;
    NSTimeInterval _duration;
}
@end

@implementation ABSeekableFileUnit

@synthesize audioUnitDelegate = _delegate, audioUnitStatus = _status, audioUnitFormat = _dataFormat;

#pragma mark - life cycle

- (id)initWithAudioUnitDelegate:(NSObject <ABAudioUnitDelegate> *)delegate
{
    self = [super init];
    if (self)
    {
        _audioFile = NULL;
        _dataFormat = [[ABAudioFormat alloc] init];
        _status = ABAudioUnitStatusEmpty;
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self audioUnitClose];
}

#pragma mark - audio unit protocol implementation

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

- (void)audioUnitOpenPath:(NSString *)path
{
    [self audioUnitClose];
    if ([self audioFileOpen:path])
    {
        [self audioFileSetupDataFormat];
        [self audioFileCalculateBufferSize];
        [self audioFileCalculateDuration];
        [self.audioUnitDelegate audioUnitDidOpen:self];
        ABAudioMetadata *metadata = [self audioFileMetadata];
        if (metadata)
        {
            [self.audioUnitDelegate audioUnit:self didReceiveMetadata:metadata];
        }
    }
    else
    {
        [self.audioUnitDelegate audioUnit:self didFail:[NSError errorAudioFileOpenPath:path]];
    }
}

- (void)audioUnitClose
{
    if (_audioFile)
    {
        AudioFileClose(_audioFile);
        _audioFile = NULL;
    }
    _duration = 0.f;
    _status = ABAudioUnitStatusEmpty;
    if (_extAudioFile)
    {
        ExtAudioFileDispose(_extAudioFile);
        _extAudioFile = NULL;
    }
}

- (ABAudioBuffer *)audioUnitCurrentBuffer
{
    UInt32 readPackets = self.audioUnitFormat.packetsToRead;
    UInt32 readFrames = self.audioUnitFormat.format->mFramesPerPacket * readPackets;
    ABAudioBuffer *buffer = [[ABAudioBuffer alloc] init];
    [buffer setExpectedDataSize:self.audioUnitFormat.bufferSize];
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mNumberChannels = self.audioUnitFormat.format->mChannelsPerFrame;
    bufferList.mBuffers[0].mDataByteSize = self.audioUnitFormat.bufferSize;
    bufferList.mBuffers[0].mData = buffer.data;
    OSStatus status = ExtAudioFileRead(_extAudioFile, &readFrames, &bufferList);
    if (status == noErr)
    {
        if (readFrames > 0)
        {
            buffer.actualDataSize = bufferList.mBuffers[0].mDataByteSize;
            _status = ABAudioUnitStatusOK;
            return buffer;
        }
        else
        {
            _status = ABAudioUnitStatusEnd;
        }
    }
    else
    {
        _status = ABAudioUnitStatusError;
    }
    return nil;
}

- (NSTimeInterval)audioUnitDuration
{
    return _duration;
}

#pragma mark - private

- (BOOL)audioFileOpen:(NSString *)path
{
    NSURL *fileURL = [NSURL URLWithString:path];
    if (fileURL)
    {
        OSStatus status = AudioFileOpenURL((__bridge CFURLRef)fileURL, kAudioFileReadPermission, 0,
                                           &_audioFile);
        if (status == noErr)
        {
            ExtAudioFileWrapAudioFileID(_audioFile, false, &_extAudioFile);
        }
        return (status == noErr);
    }
    return NO;
}

- (void)audioFileSetupDataFormat
{
    AudioStreamBasicDescription *audioFormat = self.audioUnitFormat.format;
    UInt32 dataFormatSize = sizeof(AudioStreamBasicDescription);
    AudioFileGetProperty(_audioFile, kAudioFilePropertyDataFormat, &dataFormatSize, audioFormat);
    audioFormat->mFormatID = kAudioFormatLinearPCM;
    audioFormat->mFormatFlags = kAudioFormatFlagIsSignedInteger;
    audioFormat->mBitsPerChannel = 16;// sizeof(SInt16) * 8;
    audioFormat->mFramesPerPacket = 1;
    audioFormat->mBytesPerFrame = (audioFormat->mChannelsPerFrame * audioFormat->mBitsPerChannel)
                                  / 8;
    audioFormat->mBytesPerPacket = audioFormat->mFramesPerPacket * audioFormat->mBytesPerFrame;
    ExtAudioFileSetProperty(_extAudioFile, kExtAudioFileProperty_ClientDataFormat,
                            sizeof(AudioStreamBasicDescription), audioFormat);
}

- (void)audioFileCalculateBufferSize
{
    UInt32 maxPacketSize = 0;
    UInt32 propertySize = sizeof(maxPacketSize);
    ExtAudioFileGetProperty(_extAudioFile, kExtAudioFileProperty_ClientMaxPacketSize,
                            &propertySize, &maxPacketSize);
    AudioStreamBasicDescription *dataFormat = self.audioUnitFormat.format;
    if (dataFormat->mFramesPerPacket != 0)
    {
        Float64 packetsForTime = dataFormat->mSampleRate / dataFormat->mFramesPerPacket * 0.5;
        UInt32 bufferSize = (UInt32)(packetsForTime * maxPacketSize);
        self.audioUnitFormat.bufferSize = range_value(bufferSize, 0x4000, 0x50000);
    }
    else
    {
        self.audioUnitFormat.bufferSize = MAX(0x50000, maxPacketSize);
    }
    self.audioUnitFormat.packetsToRead = self.audioUnitFormat.bufferSize / maxPacketSize;
}

- (void)audioFileCalculateDuration
{
    UInt32 size = sizeof(NSTimeInterval);
    OSStatus status = AudioFileGetProperty(_audioFile, kAudioFilePropertyEstimatedDuration, &size,
                                           &_duration);
    if (status != noErr)
    {
        _duration = 0.f;
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
    OSStatus status = AudioFileGetPropertyInfo(_audioFile, kAudioFilePropertyID3Tag, &size, NULL);
    if (status == noErr && size > 0)
    {
        char *bytes = (char *)malloc(size);
        status = AudioFileGetProperty(_audioFile, kAudioFilePropertyID3Tag, &size, bytes);
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
    if (_audioFile)
    {
        UInt32 size = 0, writable = 0;
        OSStatus status = AudioFileGetPropertyInfo(_audioFile, property, &size, &writable);
        if (status == noErr)
        {
            void *value = NULL;
            status = AudioFileGetProperty(_audioFile, property, &size, &value);
            return status == noErr ? value : NULL;
        }
    }
    return NULL;
}

@end