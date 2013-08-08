//
//  ABAudioReaderDelegate.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 8/7/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABAudioReaderDelegate <NSObject>

- (void)audioReaderDidReachEnd;

@end
