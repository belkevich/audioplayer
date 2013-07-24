//
//  ABAudioQueueDelegate.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABAudioQueueDelegate <NSObject>

- (void)audioQueueBufferEmpty;

@end
