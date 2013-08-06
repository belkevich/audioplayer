//
//  ABAudioReaderProtocol.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class ABAudioBuffer;

@protocol ABAudioReaderProtocol <NSObject>

@property (nonatomic, readonly) AudioStreamBasicDescription audioReaderDataFormat;
@property (nonatomic, readonly) UInt32 audioReaderBufferSize;

- (void)audioReaderFillAudioBuffer:(ABAudioBuffer *)buffer;

@optional

@property (nonatomic, readonly) char *audioReaderMagicCookie;
@property (nonatomic, readonly) UInt32 audioReaderMagicCookieSize;

@end
