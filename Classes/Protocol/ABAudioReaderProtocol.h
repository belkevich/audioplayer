//
//  ABAudioReaderProtocol.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol ABAudioReaderProtocol <NSObject>

@property (nonatomic, readonly) AudioStreamBasicDescription audioReaderDataFormat;
@property (nonatomic, readonly) UInt32 audioReaderBufferSize;

- (void)audioReaderFillBuffer:(AudioQueueBufferRef)buffer
            packetDescription:(AudioStreamPacketDescription **)pPacketDescription
                  readPackets:(UInt32 *)readPackets;

@optional

@property (nonatomic, readonly) char *audioReaderMagicCookie;
@property (nonatomic, readonly) UInt32 audioReaderMagicCookieSize;

@end
