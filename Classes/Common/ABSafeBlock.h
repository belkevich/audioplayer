//
//  ABSafeBlock.h
//  ABAudioPlayer
//
//  Created by Alexey Belkevich on 8/13/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#ifndef ABAudioPlayer_ABSafeBlock_h
#define ABAudioPlayer_ABSafeBlock_h

#if !defined(ABSAFE_BLOCK)
#define ABSAFE_BLOCK(block, ...) block ? block(__VA_ARGS__) : nil
#endif

#endif
