//
//  Effect.h
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, EffectType) {
    EffectTypeS = 0,
    EffectTypeE,
    EffectTypeA,
    EffectTypeL,
    EffectTypeHealthPoints,
    EffectTypeMovePoints,
    EffectTypeCriticalDamage,
    EffectTypeSwordRange,
    EffectTypeBowRange,
    EffectTypeSwordDamage,
    EffectTypeBowDamage,
    EffectTypeSwordCountAttack,
    EffectTypeBowCountAttack,
};


@interface Effect : NSObject

@property (assign, nonatomic, readonly) EffectType type;

@property (assign, nonatomic, readonly) NSInteger value;

- (instancetype)initWithType:(EffectType)type andValue:(NSUInteger)value;

@end
