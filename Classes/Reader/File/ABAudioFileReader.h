//
//  ABAudioFileReader.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioUnitProtocol.h"

@interface ABAudioFileReader : NSObject <ABAudioUnitProtocol>
{
    AudioFileID audioFile;
    NSTimeInterval duration;
    SInt64 currentPacket;
}

@end
