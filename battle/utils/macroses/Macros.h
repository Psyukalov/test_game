//
//  Macros.h
//  Macros
//
//  Created by Vladimir Psyukalov on 05.05.17.
//  Copyright © 2017 YOUROCK INC. All rights reserved.
//


#ifndef Macros_h
#define Macros_h


#define APPLICATION ([UIApplication sharedApplication])
#define DELEGATE    ([[UIApplication sharedApplication] delegate])

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(VERSION) ([[[UIDevice currentDevice] systemVersion] compare:VERSION options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO_IOS_10   (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0"))

#define WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define LOCALIZE(STRING) (NSLocalizedString(STRING, nil))
#define LOCALE           (LOCALIZE(@"locale"))

#define DEGREES_TO_RADIANS(DEGREES) (DEGREES * M_PI / 180.f)
#define RADIANS_TO_DEGREES(RADIANS) (RADIANS * 180.f / M_PI)


#endif /* Macros_h */
