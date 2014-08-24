//
//  ABAudioFileUnit.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/17/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioUnitProtocol.h"

@interface ABAudioFileUnit : NSObject <ABAudioUnitProtocol>
{
    AudioFileID audioFile;
    NSTimeInterval duration;
    SInt64 currentPacket;
}

@end
