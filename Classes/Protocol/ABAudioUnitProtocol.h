//
//  ABAudioUnitProtocol.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ABAudioUnitDelegate.h"

@class ABAudioFormat;
@class ABAudioBuffer;
@class ABAudioMetadata;

typedef enum
{
    ABAudioUnitStatusOK = 0,
    ABAudioUnitStatusEmpty = 1,
    ABAudioUnitStatusEnd = 2,
    ABAudioUnitStatusError = 3
} ABAudioUnitStatus;

@protocol ABAudioUnitProtocol <NSObject>

- (id)initWithAudioUnitDelegate:(NSObject <ABAudioUnitDelegate> *)delegate;
+ (BOOL)audioUnitCanOpenPath:(NSString *)path;

@property (nonatomic, weak, readonly) NSObject <ABAudioUnitDelegate> *audioUnitDelegate;
@property (nonatomic, strong, readonly) ABAudioFormat *audioUnitFormat;
@property (nonatomic, assign, readonly) ABAudioUnitStatus audioUnitStatus;
@property (nonatomic, assign, readonly) NSTimeInterval audioUnitDuration;

- (void)audioUnitOpenPath:(NSString *)path;
- (void)audioUnitClose;
- (ABAudioBuffer *)audioUnitCurrentBuffer;

@end
