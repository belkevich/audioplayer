//
//  Trim.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/9/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#ifndef ABAudioPlayer_Trim_h
#define ABAudioPlayer_Trim_h

#if !defined(TRIM)
#define TRIM(A,B,C)	({ __typeof__(A) __x = A > B ? A : B; __x < C ? __x : C; })
#endif

#endif
