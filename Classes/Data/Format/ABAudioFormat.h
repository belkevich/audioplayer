//
//  ABAudioFormat.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/8/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class ABAudioMagicCookie;

@interface ABAudioFormat : NSObject

@property (nonatomic, readonly) AudioStreamBasicDescription *format;
@property (nonatomic, assign) UInt32 bufferSize;
@property (nonatomic, assign) UInt32 packetsToRead;
@property (nonatomic, readonly) ABAudioMagicCookie *magicCookie;

@end
