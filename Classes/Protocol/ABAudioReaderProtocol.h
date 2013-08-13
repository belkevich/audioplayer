//
//  ABAudioReaderProtocol.h
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
    ABAudioReaderStatusOK = 0,
    ABAudioReaderStatusEmpty = 1,
    ABAudioReaderStatusEnd = 2,
    ABAudioReaderStatusError = 3
} ABAudioReaderStatus;

typedef void (^ABAudioReaderOpenSuccessBlock)();
typedef void (^ABAudioReaderOpenFailureBlock)(NSError *error);
typedef void (^ABAudioReaderMetadataReceivedBlock)(ABAudioMetadata *metadata);

@protocol ABAudioReaderProtocol <NSObject>

@property (nonatomic, readonly) ABAudioReaderStatus audioReaderStatus;
@property (nonatomic, readonly) ABAudioFormat *audioReaderFormat;

- (void)audioReaderOpenPath:(NSString *)path success:(ABAudioReaderOpenSuccessBlock)successBlock
                    failure:(ABAudioReaderOpenFailureBlock)failureBlock
           metadataReceived:(ABAudioReaderMetadataReceivedBlock)metadataReceivedBlock;
- (void)audioReaderClose;
- (ABAudioBuffer *)audioReaderCurrentBufferThreadSafely;
- (NSTimeInterval)audioReaderDuration;

@end
