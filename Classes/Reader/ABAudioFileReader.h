//
//  ABAudioFileReader.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioQueueDataSource.h"

@interface ABAudioFileReader : NSObject <ABAudioQueueDataSource>
{
    AudioFileID audioFile;
    SInt64 packetCount;
    UInt32 cookieSize;
}

- (BOOL)openAudio:(NSString *)path;
- (void)closeAudio;

@end
