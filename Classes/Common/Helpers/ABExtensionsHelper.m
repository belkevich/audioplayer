//
//  ABExtensionsHelper.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/23/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABExtensionsHelper.h"

@implementation ABExtensionsHelper

+ (NSArray *)nativeAudioExtensions
{
    return @[@"l16", @"wav", @"aiff", @"au", @"pcm", @"ima4", @"lbc", @"3gp", @"mp4", @"dvb",
             @"m4a", @"m4b", @"m4p", @"m4v", @"m4r", @"aac", @"mp3"];
}

@end
