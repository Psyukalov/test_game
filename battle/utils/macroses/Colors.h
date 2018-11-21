//
//  Colors.h
//  Colors
//
//  Created by Vladimir Psyukalov on 06.04.18.
//  Copyright © 2018 YOUROCK INC. All rights reserved.
//


#ifndef Colors_h
#define Colors_h


#define RGBA(R, G, B, A) ([UIColor colorWithRed:R / 255.f green:G / 255.f blue:B / 255.f alpha:A])
#define RGB(R, G, B)     (RGBA(R, G, B, 1.f))


#endif /* Colors_h */
