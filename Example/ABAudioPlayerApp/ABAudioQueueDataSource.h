//
//  ABAudioQueueDataSource.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol ABAudioQueueDataSource <NSObject>

- (void)audioQueueSetupDataFormat:(AudioStreamBasicDescription *)dataFormat;
- (void)audioQueueFillBuffer:(AudioQueueBufferRef)dataBuffer;

@end
