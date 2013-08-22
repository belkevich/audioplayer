//
//  ABAudioMetadata.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABAudioMetadata : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *album;
@property (nonatomic, readonly) NSString *genre;
@property (nonatomic, readonly) NSString *comments;
@property (nonatomic, readonly) NSNumber *year;
@property (nonatomic, readonly) NSNumber *track;
@property (nonatomic, readonly) NSNumber *tempo;
#if TARGET_OS_IPHONE
@property (nonatomic, readonly) UIImage *artwork;
#else
@property (nonatomic, readonly) NSImage *artwork;
#endif

- (id)initWithAudioFileMetadataDictionary:(NSDictionary *)dictionary;
- (void)artworkWithData:(NSData *)data;
- (void)id3TagsWithData:(NSData *)data;

@end
