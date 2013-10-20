//
//  ABSeekableFileReader.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 10/15/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioReaderProtocol.h"

@interface ABSeekableFileReader : NSObject <ABAudioReaderProtocol>
{
    ExtAudioFileRef extAudioFile;
    AudioFileID audioFile;
    NSTimeInterval duration;
}

@end
