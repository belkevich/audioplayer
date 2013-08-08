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
    SInt64 packetCount;
}

@end
