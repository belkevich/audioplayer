//
//  ABAudioPlayer.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 7/25/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABAudioPlayer.h"
#import "ABAudioQueue.h"
#import "ABAudioFileReader.h"
#import "ABAudioBuffer.h"
#import "ABAudioFormat.h"

@implementation ABAudioPlayer

#pragma mark - public

- (void)play
{
    audioFile = [[ABAudioFileReader alloc] init];
    audioFile.audioReaderDelegate = self;
    [audioFile audioReaderOpen:@"/Users/alex/Music/01.mp3"];
    audioQueue = [[ABAudioQueue alloc] initWithAudioQueueDataSource:self delegate:self];
    [audioQueue audioQueueSetupFormat:audioFile.audioReaderFormat];
    [audioQueue audioQueuePlay];
}

#pragma mark - audio queue data source implementation

- (ABAudioBuffer *)audioQueueCurrentBuffer
{
    return [audioFile audioReaderCurrentBuffer];
}

#pragma mark - audio queue delegate implementation

- (void)audioQueueBufferEmpty
{
    NSLog(@"buffer empty");
}

#pragma mark - audio reader delegate implementation

- (void)audioReaderDidReachEnd
{
    [audioQueue audioQueueStop];
}

@end
