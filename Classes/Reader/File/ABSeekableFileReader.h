//
//  ABSeekableFileReader.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 10/15/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioUnitProtocol.h"

@interface ABSeekableFileReader : NSObject <ABAudioUnitProtocol>
{
    ExtAudioFileRef extAudioFile;
    AudioFileID audioFile;
    NSTimeInterval duration;
}

@end
