//
//  ABAudioUnitBuilder.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/22/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAudioUnitProtocol.h"

@interface ABAudioUnitBuilder : NSObject

- (id)initWithAudioUnitDelegate:(NSObject <ABAudioUnitDelegate> *)delegate;
- (void)addAudioUnitClass:(Class)theClass;
- (void)removeAudioUnitClass:(Class)theClass;
- (NSObject <ABAudioUnitProtocol> *)audioUnitForSource:(NSString *)source;

@end
