//
//  ABAudioUnitDelegate.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 8/24/14.
//  Copyright (c) 2014 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABAudioUnitProtocol;
@class ABAudioMetadata;

@protocol ABAudioUnitDelegate <NSObject>

- (void)audioUnitDidOpen:(NSObject <ABAudioUnitProtocol> *)audioUnit;
- (void)audioUnit:(NSObject <ABAudioUnitProtocol> *)audioUnit didFail:(NSError *)error;
- (void)audioUnit:(NSObject <ABAudioUnitProtocol> *)audioUnit
didReceiveMetadata:(ABAudioMetadata *)metadata;

@end
