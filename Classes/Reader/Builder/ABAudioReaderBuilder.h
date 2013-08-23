//
//  ABAudioReaderBuilder.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/22/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioReaderProtocol.h"

@interface ABAudioReaderBuilder : NSObject
{
    NSArray *readerClassNames;
    NSObject <ABAudioReaderProtocol> *currentAudioReader;
}

- (id)initWithReaderClassNames:(NSArray *)classNames;
- (NSObject <ABAudioReaderProtocol> *)audioReaderForSourcePath:(NSString *)path;

@end
