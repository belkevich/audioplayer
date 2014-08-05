//
//  ABAudioUnitProtocol.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

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

typedef void (^ABAudioReaderOpenSuccessBlock)();
typedef void (^ABAudioReaderOpenFailureBlock)(NSError *error);
typedef void (^ABAudioReaderMetadataReceivedBlock)(ABAudioMetadata *metadata);

@protocol ABAudioUnitProtocol <NSObject>

+ (BOOL)audioUnitCanOpenPath:(NSString *)path;

@property (nonatomic, readonly) ABAudioUnitStatus audioUnitStatus;
@property (nonatomic, readonly) ABAudioFormat *audioUnitFormat;
@property (nonatomic, readonly) NSTimeInterval audioUnitDuration;

- (void)audioUnitOpenPath:(NSString *)path success:(ABAudioReaderOpenSuccessBlock)successBlock
                  failure:(ABAudioReaderOpenFailureBlock)failureBlock
         metadataReceived:(ABAudioReaderMetadataReceivedBlock)metadataReceivedBlock;
- (void)audioUnitClose;
- (ABAudioBuffer *)audioUnitCurrentBufferThreadSafely;

@end
