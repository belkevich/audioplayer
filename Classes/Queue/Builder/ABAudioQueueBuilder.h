//
//  ABAudioQueueBuilder.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/9/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class ABAudioFormat;

@interface ABAudioQueueBuilder : NSObject

+ (AudioQueueRef)audioQueueWithFormat:(ABAudioFormat *)format
                             callback:(AudioQueueOutputCallback)callback owner:(id)owner;

@end
