//
//  ABAudioUnitBuilder.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/22/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioUnitBuilder.h"

@interface ABAudioUnitBuilder ()
{
    NSMutableSet *_availableUnits;
    NSObject <ABAudioUnitProtocol> *_currentUnit;
}
@end

@implementation ABAudioUnitBuilder

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _availableUnits = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark - public

- (void)addAudioUnitClass:(Class)theClass
{
    NSString *className = NSStringFromClass(theClass);
    if ([theClass conformsToProtocol:@protocol(ABAudioUnitProtocol)])
    {
        if (![_availableUnits containsObject:className])
        {
            [_availableUnits addObject:className];
        }
    }
    else
    {
        NSString *protocolName = NSStringFromProtocol(@protocol(ABAudioUnitProtocol));
        NSString *reason = [NSString stringWithFormat:@"'%@' class doesn't conform '%@'",
                                                      className, protocolName];
        @throw [NSException exceptionWithName:@"Wrong Audio Unit Class" reason:reason
                                     userInfo:nil];
    }
}

- (void)removeAudioUnitClass:(Class)theClass
{
    [_availableUnits removeObject:NSStringFromClass(theClass)];
}

- (NSObject <ABAudioUnitProtocol> *)audioUnitForSource:(NSString *)source
{
    Class unitClass = [self findAudioUnitClassForSource:source];
    if (![_currentUnit isMemberOfClass:unitClass])
    {
        _currentUnit = [[unitClass alloc] init];
    }
    return _currentUnit;
}

#pragma mark - private

- (Class)findAudioUnitClassForSource:(NSString *)source
{
    __block Class unitClass = nil;
    [_availableUnits enumerateObjectsUsingBlock:^(NSString *name, BOOL *stop) {
        Class <ABAudioUnitProtocol> currentClass = NSClassFromString(name);
        if ([currentClass audioReaderCanOpenPath:source])
        {
            unitClass = currentClass;
            *stop = YES;
        }
    }];
    return unitClass;
}

@end
