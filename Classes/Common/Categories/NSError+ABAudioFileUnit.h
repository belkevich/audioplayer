//
//  NSError+ABAudioFileUnit.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/13/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (ABAudioFileUnit)

+ (NSError *)errorAudioFileOpenPath:(NSString *)path;

@end
