//
//  ABAudioFileReader.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioReaderProtocol.h"


@interface ABAudioFileReader : NSObject <ABAudioReaderProtocol>
{
    AudioFileID audioFile;
    AudioStreamBasicDescription dataFormat;
    char *magicCookie;
    UInt32 bufferSize;
    UInt32 packetsToRead;
    SInt64 packetCount;
}

- (BOOL)openAudio:(NSString *)path;
- (void)closeAudio;

@end
