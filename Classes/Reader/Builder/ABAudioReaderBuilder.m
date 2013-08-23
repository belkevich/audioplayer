//
//  ABAudioReaderBuilder.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/22/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioReaderBuilder.h"

@implementation ABAudioReaderBuilder

#pragma mark - life cycle

- (id)initWithReaderClassNames:(NSArray *)classNames
{
    self = [super init];
    if (self)
    {
        for (NSString *name in classNames)
        {
            Class readerClass = NSClassFromString(name);
            if (![readerClass conformsToProtocol:@protocol(ABAudioReaderProtocol)])
            {
                NSString *protocolName = NSStringFromProtocol(@protocol(ABAudioReaderProtocol));
                NSString *reason = [NSString stringWithFormat:@"'%@' class doesn't conform '%@'",
                                                              protocolName, name];
                @throw [NSException exceptionWithName:@"Wrong audio reader class" reason:reason
                                             userInfo:nil];
            }
        }
        readerClassNames = classNames;
    }
    return self;
}

#pragma mark - public

- (NSObject <ABAudioReaderProtocol> *)audioReaderForSourcePath:(NSString *)path
{
    Class readerClass = [self audioReaderClassForSourcePath:path];
    if (![currentAudioReader isMemberOfClass:readerClass])
    {
        currentAudioReader = [[readerClass alloc] init];
    }
    return currentAudioReader;
}

#pragma mark - private

- (Class)audioReaderClassForSourcePath:(NSString *)path
{
    for (NSString *name in readerClassNames)
    {
        Class <ABAudioReaderProtocol> readerClass = NSClassFromString(name);
        if ([readerClass audioReaderCanOpenPath:path])
        {
            return readerClass;
        }
    }
    return nil;
}

@end
