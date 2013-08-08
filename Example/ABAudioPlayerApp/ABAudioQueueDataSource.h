//
//  ABAudioQueueDataSource.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABAudioBuffer;

@protocol ABAudioQueueDataSource <NSObject>

- (ABAudioBuffer *)audioQueueCurrentBuffer;

@end
