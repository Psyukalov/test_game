//
//  Card.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "Card.h"


#define NAME_FORMAT (@"localized_card_name_%@")
#define TEXT_FORMAT (@"localized_card_text_%@")


@implementation Card

#pragma mark - Initializations methods

- (instancetype)initWithIdentifier:(NSString *)identifier andEffects:(NSArray<Effect *> *)effects {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _effects    = effects;
    }
    return self;
}

#pragma mark - Private methods

- (NSUInteger)effectValueWithType:(EffectType)type {
    for (Effect *effect in _effects) {
        if (effect.type == type) {
            return effect.value;
        }
    }
    return 0;
}

#pragma mark - Public properties

- (NSString *)name {
    NSString *key = [NSString stringWithFormat:NAME_FORMAT, _identifier];
    return NSLocalizedString(key, nil);
}

- (NSString *)text {
    NSString *key = [NSString stringWithFormat:TEXT_FORMAT, _identifier];
    return NSLocalizedString(key, nil);
}

@end
