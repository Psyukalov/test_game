//
//  Player.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "Player.h"


#define BASE_HEALTH_POINTS      (50)
#define BASE_MOVE_POINTS        (5)
#define BASE_SWORD_DAMAGE       (16)
#define BASE_BOW_DAMAGE         (4)
#define BASE_CRITICAL_PERCENT   (40)
#define BASE_SWORD_RANGE        (1)
#define BASE_BOW_RANGE          (4)
#define BASE_COUNT_ATTACK_SWORD (1)
#define BASE_COUNT_ATTACK_BOW   (1)


#define S_KEY (@"s")
#define E_KEY (@"e")
#define A_KEY (@"a")
#define L_KEY (@"l")
#define CARD_IDENTIFIER_KEY (@"cardIdentifier")


@interface Player ()



@end


@implementation Player

#pragma mark - Initialization methods

- (instancetype)initWithParametrs:(Parameters)parameters andCard:(Card *)card {
    self = [super init];
    if (self) {
        _parameters = parameters;
        _card       = card;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSUInteger  S = 0;
        NSUInteger  E = 0;
        NSUInteger  A = 0;
        NSUInteger  L = 0;
        NSString   *cardIdentifier;
        @try {
            S = [dictionary[S_KEY] integerValue];
            E = [dictionary[E_KEY] integerValue];
            A = [dictionary[A_KEY] integerValue];
            L = [dictionary[L_KEY] integerValue];
            cardIdentifier = dictionary[CARD_IDENTIFIER_KEY];
        } @catch (NSException *exception) {
            // Empty...
        }
        _parameters = ParametersMake(S, E, A, L);
        _card       = [[CardsManager shared] cardWithIdentifier:cardIdentifier];
    }
    return self;
}

#pragma mark - Private methods

- (BOOL)criticalDamage {
    NSInteger  value   = _parameters.L + [_card effectValueWithType:EffectTypeL];
    CGFloat    percent = 0.1f * (CGFloat)(value < 0 ? 0 : value);
    NSUInteger result  = percent * BASE_CRITICAL_PERCENT + [_card effectValueWithType:EffectTypeCriticalChance];
    NSUInteger random  = arc4random_uniform(100) + 1;
    NSUInteger half    = result / 2;
    return random >= 50 - half && random <= 50 + half;
}

- (void)checkEndAttacks {
    if (!self.canMakeAttackSword && !self.canMakeAttackBow) {
        if ([_delegate respondsToSelector:@selector(didEndAttacksWithPlayer:)]) {
            [_delegate didEndAttacksWithPlayer:self];
        }
    }
}

- (void)checkEndTurn {
    if (_movePoints == 0 && !self.canMakeAttackSword && !self.canMakeAttackBow) {
        if ([_delegate respondsToSelector:@selector(didEndTurnWithPlayer:)]) {
            [_delegate didEndTurnWithPlayer:self];
        }
    }
}

- (void)didReceiveCountsAttack {
    if ([_delegate respondsToSelector:@selector(didReceiveCountsAttackWithPlayer:)]) {
        [_delegate didReceiveCountsAttackWithPlayer:self];
    }
}

- (void)didReceiveDamage {
    if ([_delegate respondsToSelector:@selector(didReceiveDamageWithPlayer:)]) {
        [_delegate didReceiveDamageWithPlayer:self];
    }
}

#pragma mark - Public methods

- (void)resetHealthPoints {
    _healthPoints = [@(self.maxHealthPoints) integerValue];
}

- (void)resetMovePoints {
    _movePoints = [@(self.maxMovePoints) integerValue];
}

- (void)resetAttacks {
    _countAttackSword = BASE_COUNT_ATTACK_SWORD + [_card effectValueWithType:EffectTypeSwordCountAttack];
    _countAttackBow   = BASE_COUNT_ATTACK_BOW   + [_card effectValueWithType:EffectTypeBowCountAttack];
}

- (void)reset {
    [self resetHealthPoints];
    [self resetMovePoints];
    [self resetAttacks];
}

- (NSUInteger)swordDamageAsCrititcal:(BOOL *)critical {
    *critical         = [self criticalDamage];
    NSInteger valueS  = _parameters.S     + [_card effectValueWithType:EffectTypeS];
    NSInteger valueE  = _parameters.E / 2 + [_card effectValueWithType:EffectTypeE];
    CGFloat   percent = 0.1f * (CGFloat)((valueS < 0 ? 0 : valueS) + (valueE < 0 ? 0 : valueE));
    [self checkEndAttacks];
    [self checkEndTurn];
    return BASE_SWORD_DAMAGE * (percent == 0.0f ? 0.1f : percent) + (*critical ? 1.0f : 0.0f) * BASE_SWORD_DAMAGE + [_card effectValueWithType:EffectTypeSwordDamage];
}

- (NSUInteger)bowDamageAsCrititcal:(BOOL *)critical {
    *critical         = [self criticalDamage];
    NSInteger valueS  = _parameters.S / 2 + [_card effectValueWithType:EffectTypeS];
    NSInteger valueA  = _parameters.A     + [_card effectValueWithType:EffectTypeA];
    CGFloat   percent = 0.1f * (CGFloat)((valueS < 0 ? 0 : valueS) + (valueA < 0 ? 0 : valueA));
    [self checkEndAttacks];
    [self checkEndTurn];
    return BASE_BOW_DAMAGE * (percent == 0.0f ? 0.1f : percent) + (*critical ? 2.0f : 0.0f) * BASE_BOW_DAMAGE + [_card effectValueWithType:EffectTypeBowDamage];
}

- (void)addDamage:(NSUInteger)damage {
    _healthPoints -= damage;
    if (_healthPoints < 0) {
        _healthPoints = 0;
    }
    [self didReceiveDamage];
    if (_healthPoints == 0) {
        if ([_delegate respondsToSelector:@selector(didEndHealthPointsWithPlayer:)]) {
            [_delegate didEndHealthPointsWithPlayer:self];
        }
    }
}

- (void)addHealthPoints:(NSInteger)healthPoints {
    _healthPoints += healthPoints;
    NSUInteger maxHealthPoints = self.maxHealthPoints;
    if (_healthPoints > maxHealthPoints) {
        _healthPoints = maxHealthPoints;
    } else if (_healthPoints < 0) {
        _healthPoints = 0;
    }
    if (healthPoints > 0) {
        if ([_delegate respondsToSelector:@selector(didReceiveHealthPointsWithPlayer:)]) {
            [_delegate didReceiveHealthPointsWithPlayer:self];
        }
    } else {
        [self didReceiveDamage];
    }
}

- (BOOL)makeMove {
    if (self.canMakeMove) {
        _movePoints--;
        if (_movePoints == 0) {
            if ([_delegate respondsToSelector:@selector(didEndMovePointsWithPlayer:)]) {
                [_delegate didEndMovePointsWithPlayer:self];
            }
            [self checkEndTurn];
        }
        return YES;
    }
    return NO;
}

- (void)addMovePoints:(NSInteger)movePoints {
    _movePoints += movePoints;
    NSUInteger maxMovePoints = self.maxMovePoints;
    if (_movePoints > maxMovePoints) {
        _movePoints = maxMovePoints;
    } else if (_movePoints < 0) {
        _movePoints = 0;
    }
    if ([_delegate respondsToSelector:@selector(didReceiveMovePointsWithPlayer:)]) {
        [_delegate didReceiveMovePointsWithPlayer:self];
    }
}

- (void)makeAttackSword {
    if (self.canMakeAttackSword) {
        _countAttackSword--;
    }
}

- (void)makeAttackBow {
    if (self.canMakeAttackBow) {
        _countAttackBow--;
    }
}

- (void)addCountAttackSword:(NSInteger)count {
    _countAttackSword += count;
    if (_countAttackSword < 0) {
        _countAttackSword = 0;
    }
    [self didReceiveCountsAttack];
}

- (void)addCountAttackBow:(NSInteger)count {
    _countAttackBow += count;
    if (_countAttackBow < 0) {
        _countAttackBow = 0;
    }
    [self didReceiveCountsAttack];
}

#pragma mark - Public properties

- (BOOL)canMakeMove {
    return _movePoints > 0;
}

- (BOOL)canMakeAttackSword {
    return _countAttackSword > 0;
}

- (BOOL)canMakeAttackBow {
    return _countAttackBow > 0;
}

- (NSUInteger)maxHealthPoints {
    NSInteger value   = _parameters.E + [_card effectValueWithType:EffectTypeE];
    CGFloat   percent = 0.1f * (CGFloat)(value < 0 ? 0 : value);
    NSInteger result  = BASE_HEALTH_POINTS + (2 * BASE_HEALTH_POINTS) * percent;
    NSInteger effect  = [_card effectValueWithType:EffectTypeHealthPoints];
    return (result + effect <= 0) ? 1 : result + effect;
}

- (NSUInteger)maxMovePoints {
    NSInteger value   = _parameters.A + [_card effectValueWithType:EffectTypeA];
    CGFloat   percent = 0.1f * (CGFloat)(value < 0 ? 0 : value);
    NSInteger result  = BASE_MOVE_POINTS + (2 * BASE_MOVE_POINTS) * percent;
    NSInteger effect  = [_card effectValueWithType:EffectTypeMovePoints];
    return (result + effect <= 0) ? 1 : result + effect;
}

- (NSUInteger)swordRange {
    NSInteger valueA  = _parameters.A / 2 + [_card effectValueWithType:EffectTypeA];
    NSInteger valueS  = _parameters.S     + [_card effectValueWithType:EffectTypeS];
    CGFloat   percent = 0.1f * ((CGFloat)(valueA < 0 ? 0 : valueA) + (CGFloat)(valueS < 0 ? 0 : valueS));
    NSInteger result  = BASE_SWORD_RANGE + BASE_SWORD_RANGE * percent;
    NSInteger effect  = [_card effectValueWithType:EffectTypeSwordRange];
    return (result + effect <= 0) ? 1 : result + effect;
}

- (NSUInteger)bowRange {
    NSInteger valueA = _parameters.A     + [_card effectValueWithType:EffectTypeA];
    NSInteger valueE = _parameters.E / 2 + [_card effectValueWithType:EffectTypeE];
    CGFloat   percent = 0.1f * ((CGFloat)(valueA < 0 ? 0 : valueA) + (CGFloat)(valueE < 0 ? 0 : valueE));
    NSInteger result  = BASE_BOW_RANGE + BASE_BOW_RANGE * percent;
    NSInteger effect  = [_card effectValueWithType:EffectTypeBowRange];
    return (result + effect <= 0) ? 1 : result + effect;
}

- (NSDictionary *)dictionary {
    return @{S_KEY : @(_parameters.S),
             E_KEY : @(_parameters.E),
             A_KEY : @(_parameters.A),
             L_KEY : @(_parameters.L),
             CARD_IDENTIFIER_KEY : _card.identifier};
}

@end
