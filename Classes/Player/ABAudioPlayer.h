//
//  ABAudioPlayer.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/25/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioPlayerDelegate.h"
#import "ABAudioQueueDataSource.h"

@class ABAudioReaderBuilder;

@interface ABAudioPlayer : NSObject <ABAudioQueueDataSource>
{
    ABAudioReaderBuilder *audioReaderBuilder;
}

@property (nonatomic, weak) NSObject <ABAudioPlayerDelegate> *delegate;
@property (nonatomic, readonly) ABAudioPlayerStatus status;
@property (nonatomic, readonly) NSString *source;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float pan;
@property (nonatomic, readonly) NSTimeInterval time;
@property (nonatomic, readonly) NSTimeInterval duration;

- (id)initWithAudioReaderClass:(Class)readerClass;
- (id)initWithAudioReaderClassNames:(NSArray *)classNames;
- (void)playerPlaySource:(NSString *)path;
- (void)playerStart;
- (void)playerStop;
- (void)playerPause;

@end
