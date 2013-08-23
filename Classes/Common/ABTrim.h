//
//  ABTrim.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/9/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#ifndef ABAudioPlayer_ABTrim_h
#define ABAudioPlayer_ABTrim_h

#if !defined(ABTRIM)
#define ABTRIM(A,B,C)	({ __typeof__(A) __x = A > B ? A : B; __x < C ? __x : C; })
#endif

#endif
