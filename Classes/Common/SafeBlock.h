//
//  SafeBlock.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/13/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#ifndef ABAudioPlayer_SafeBlock_h
#define ABAudioPlayer_SafeBlock_h

#if !defined(SAFE_BLOCK)
#define SAFE_BLOCK(block, ...) block ? block(__VA_ARGS__) : nil
#endif

#endif
