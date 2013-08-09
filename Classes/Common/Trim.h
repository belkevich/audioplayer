//
//  Trim.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/9/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#ifndef ABAudioPlayerApp_Trim_h
#define ABAudioPlayerApp_Trim_h

#if !defined(TRIM)
#define TRIM(A,B,C)	({ __typeof__(A) __x = MAX(A,B); __x = MIN(__x, C); __x; })
#endif

#endif
