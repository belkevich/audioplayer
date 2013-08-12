//
//  NSDictionary+UTF8Key.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (UTF8Key)

- (id)valueForUTF8Key:(void const *)key;

@end
