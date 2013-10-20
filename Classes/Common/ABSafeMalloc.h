//
//  ABSafeMalloc.h
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 10/15/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#ifndef ABAudioPlayerApp_ABSafeMalloc_h
#define ABAudioPlayerApp_ABSafeMalloc_h

#if !defined(ABSAFE_MALLOC)
#define ABSAFE_MALLOC(size) size > 0 ? malloc(size) : NULL;
#endif


#endif
