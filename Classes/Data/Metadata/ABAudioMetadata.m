//
//  ABAudioMetadata.m
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "ABAudioMetadata.h"
#import "NSDictionary+UTF8Key.h"

@interface ABAudioMetadata ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *comments;
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) NSNumber *track;
@property (nonatomic, strong) NSNumber *tempo;
#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage *artwork;
#else
@property (nonatomic, strong) NSImage *artwork;
#endif

@end

@implementation ABAudioMetadata

#pragma mark - life cycle

- (id)initWithAudioFileMetadataDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        [self parseAudioFileDictionary:dictionary];
    }
    return self;
}

#pragma mark - public

- (void)artworkWithData:(NSData *)data
{
#if TARGET_OS_IPHONE
    UIImage *image = [[UIImage alloc] initWithData:data];
#else
    NSImage *image = [[NSImage alloc] initWithData:data];
#endif
    self.artwork = image;
}

#pragma mark - private

- (void)parseAudioFileDictionary:(NSDictionary *)dictionary
{
    self.title = [dictionary valueForUTF8Key:kAFInfoDictionary_Title];
    self.artist = [dictionary valueForUTF8Key:kAFInfoDictionary_Artist];
    self.album = [dictionary valueForUTF8Key:kAFInfoDictionary_Album];
    self.genre = [dictionary valueForUTF8Key:kAFInfoDictionary_Genre];
    self.comments = [dictionary valueForUTF8Key:kAFInfoDictionary_Comments];
    self.year = [dictionary valueForUTF8Key:kAFInfoDictionary_Year];
    self.track = [dictionary valueForUTF8Key:kAFInfoDictionary_TrackNumber];
    self.tempo = [dictionary valueForUTF8Key:kAFInfoDictionary_Tempo];
}

@end
