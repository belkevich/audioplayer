//
//  NSError+ABAudioQueue.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/14/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (ABAudioQueue)

+ (NSError *)errorAudioQueueSetup;
+ (NSError *)errorAudioQueuePlay;

@end
