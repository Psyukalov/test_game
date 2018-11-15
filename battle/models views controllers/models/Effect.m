//
//  Effect.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "Effect.h"


@implementation Effect

#pragma mark - Initializations methods

- (instancetype)initWithType:(EffectType)type andValue:(NSUInteger)value {
    self = [super init];
    if (self) {
        _type  = type;
        _value = value;
    }
    return self;
}

@end
