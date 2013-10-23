//
//  ABAudioQueueBuilder.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/9/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "ABAudioQueueBuilder.h"
#import "ABAudioFormat.h"
#import "ABAudioMagicCookie.h"

@interface ABAudioQueueBuilder ()
@property (nonatomic, strong) ABAudioFormat *format;
@property (nonatomic, assign) AudioQueueRef queue;
@end

@implementation ABAudioQueueBuilder

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        self.queue = NULL;
    }
    return self;
}

#pragma mark - public

+ (AudioQueueRef)audioQueueWithFormat:(ABAudioFormat *)format
                             callback:(AudioQueueOutputCallback)callback owner:(id)owner
{
    ABAudioQueueBuilder *builder = [[ABAudioQueueBuilder alloc] init];
    builder.format = format;
    if ([builder audioQueueNewOutputWithCallback:callback owner:owner])
    {
        [builder audioQueueSetupMagicCookies];
        return builder.queue;
    }
    return NULL;
}

#pragma mark - private

- (BOOL)audioQueueNewOutputWithCallback:(AudioQueueOutputCallback)callback owner:(id)owner
{
    if (self.format)
    {
        AudioQueueRef queue = NULL;
        OSStatus status = AudioQueueNewOutput(self.format.format, callback,
                                              (__bridge void *)(owner), NULL, NULL, 0, &queue);
        if (status == noErr)
        {
            self.queue = queue;
            return YES;
        }
    }
    return NO;
}

- (void)audioQueueSetupMagicCookies
{
    if (self.format.magicCookie.isValid)
    {
        AudioQueueSetProperty(self.queue, kAudioQueueProperty_MagicCookie,
                              self.format.magicCookie.data, self.format.magicCookie.size);
    }
}

@end
