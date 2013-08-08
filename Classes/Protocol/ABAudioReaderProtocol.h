//
//  ABAudioReaderProtocol.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/30/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ABAudioReaderDelegate.h"

@class ABAudioFormat;
@class ABAudioBuffer;

@protocol ABAudioReaderProtocol <NSObject>

@property (nonatomic, weak) NSObject <ABAudioReaderDelegate> *audioReaderDelegate;
@property (nonatomic, readonly) ABAudioFormat *audioReaderFormat;

- (BOOL)audioReaderOpen:(NSString *)path;
- (void)audioReaderClose;
- (ABAudioBuffer *)audioReaderCurrentBuffer;

@end
