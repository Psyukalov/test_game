//
//  Player.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "Player.h"


#define BASE_HEALTH_POINTS      (100)
#define BASE_MOVE_POINTS        (10)
#define BASE_SWORD_DAMAGE       (32)
#define BASE_BOW_DAMAGE         (8)
#define BASE_CRITICAL_PERCENT   (32)
#define BASE_SWORD_RANGE        (1)
#define BASE_BOW_RANGE          (6)
#define BASE_COUNT_ATTACK_SWORD (1)
#define BASE_COUNT_ATTACK_BOW   (1)


#define S_KEY (@"s")
#define E_KEY (@"e")
#define A_KEY (@"a")
#define L_KEY (@"l")
#define CARD_IDENTIFIER_KEY (@"cardIdentifier")


@interface Player ()

@property (assign, nonatomic) NSUInteger baseHealthPoints;
@property (assign, nonatomic) NSUInteger baseMovePoints;
@property (assign, nonatomic) NSUInteger baseSwordDamage;
@property (assign, nonatomic) NSUInteger baseBowDamage;
@property (assign, nonatomic) NSUInteger baseCriticalPercent;
@property (assign, nonatomic) NSUInteger baseSwordRange;
@property (assign, nonatomic) NSUInteger baseBowRange;

@end


@implementation Player

#pragma mark - Initialization methods

- (instancetype)initWithParametrs:(Parameters)parameters andCard:(Card *)card {
    self = [super init];
    if (self) {
        _parameters = parameters;
        _card       = card;
        [self setup];
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
        [self setup];
    }
    return self;
}

#pragma mark - Private methods

- (void)setup {
    _baseHealthPoints    = BASE_HEALTH_POINTS;
    _baseMovePoints      = BASE_MOVE_POINTS;
    _baseSwordDamage     = BASE_SWORD_DAMAGE;
    _baseBowDamage       = BASE_BOW_DAMAGE;
    _baseCriticalPercent = BASE_CRITICAL_PERCENT;
    _baseSwordRange      = BASE_SWORD_RANGE;
    _baseBowRange        = BASE_BOW_RANGE;
}

- (BOOL)criticalDamage {
    NSUInteger random = arc4random_uniform(100) + 1;
    NSInteger  value  = _parameters.L + [_card effectValueWithType:EffectTypeL];
    NSInteger  percent = _baseCriticalPercent * (value < 0 ? 0 : value) / 10 + [_card effectValueWithType:EffectTypeCriticalDamage];
    return percent > 0 && percent <= random;
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

#pragma mark - Public methods

- (void)resetHealthPoints {
    _healthPoints = [@(self.maxHealthPoints) integerValue];
}

- (void)resetMovePoints {
    _movePoints = [@(self.maxMovePoints) integerValue];
}

- (void)resetAttacks {
    _countAttackSword = BASE_COUNT_ATTACK_SWORD + [_card effectValueWithType:EffectTypeSwordCountAttack];
    _countAttackBow   = BASE_COUNT_ATTACK_BOW + [_card effectValueWithType:EffectTypeBowCountAttack];
}

- (void)reset {
    [self resetHealthPoints];
    [self resetMovePoints];
    [self resetAttacks];
}

- (NSUInteger)swordDamageAsCrititcal:(BOOL *)critical {
    *critical            = [self criticalDamage];
    NSInteger valueS     = _parameters.S + [_card effectValueWithType:EffectTypeS];
    NSInteger valueE     = _parameters.E + [_card effectValueWithType:EffectTypeE];
    [self checkEndAttacks];
    [self checkEndTurn];
    return (NSUInteger)((CGFloat)_baseSwordDamage * (0.1f * ((CGFloat)(valueS < 0 ? 0 : valueS) + (CGFloat)(valueE < 0 ? 0 : valueE)))) + (*critical ? 1.0f : 0.0f) * _baseSwordDamage + [_card effectValueWithType:EffectTypeSwordDamage];
}

- (NSUInteger)bowDamageAsCrititcal:(BOOL *)critical {
    *critical         = [self criticalDamage];
    NSInteger valueS  = _parameters.S + [_card effectValueWithType:EffectTypeS];
    NSInteger valueA  = _parameters.A + [_card effectValueWithType:EffectTypeA];
    [self checkEndAttacks];
    [self checkEndTurn];
    return (NSUInteger)((CGFloat)_baseBowDamage * (0.1f * ((CGFloat)(valueS < 0 ? 0 : valueS) + (CGFloat)(valueA < 0 ? 0 : valueA)))) + (*critical ? 1.0f : 0.0f) * _baseBowDamage  + [_card effectValueWithType:EffectTypeBowDamage];
}

- (void)addDamage:(NSUInteger)damage {
    _healthPoints -= damage;
    if (_healthPoints < 0) {
        _healthPoints = 0;
    }
    if ([_delegate respondsToSelector:@selector(didReceiveDamageWithPlayer:)]) {
        [_delegate didReceiveDamageWithPlayer:self];
    }
    if (_healthPoints == 0) {
        if ([_delegate respondsToSelector:@selector(didEndHealthPointsWithPlayer:)]) {
            [_delegate didEndHealthPointsWithPlayer:self];
        }
    }
}

- (void)addHealthPoints:(NSUInteger)healthPoints {
    _healthPoints += healthPoints;
    NSUInteger maxHealthPoints = self.maxHealthPoints;
    if (_healthPoints > maxHealthPoints) {
        _healthPoints = maxHealthPoints;
    }
    if ([_delegate respondsToSelector:@selector(didReceiveHealthPointsWithPlayer:)]) {
        [_delegate didReceiveHealthPointsWithPlayer:self];
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

- (void)addMovePoints:(NSUInteger)movePoints {
    _movePoints += movePoints;
    NSUInteger maxMovePoints = self.maxMovePoints;
    if (_movePoints > maxMovePoints) {
        _movePoints = maxMovePoints;
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

- (void)addCountAttackSword:(NSUInteger)count {
    _countAttackSword += count;
    [self didReceiveCountsAttack];
}

- (void)addCountAttackBow:(NSUInteger)count {
    _countAttackBow += count;
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
    NSInteger valueE = _parameters.E + [_card effectValueWithType:EffectTypeE];
    return _baseHealthPoints + (NSUInteger)((CGFloat)_baseHealthPoints * 0.1f * (CGFloat)(valueE < 0 ? 0 : valueE)) + [_card effectValueWithType:EffectTypeHealthPoints];
}

- (NSUInteger)maxMovePoints {
    NSInteger valueA = _parameters.A + [_card effectValueWithType:EffectTypeA];
    return _baseMovePoints + (NSUInteger)((CGFloat)_baseMovePoints * 0.1f * (CGFloat)(valueA < 0 ? 0 : valueA)) + [_card effectValueWithType:EffectTypeMovePoints];
}

- (NSUInteger)swordRange {
    NSInteger valueA = _parameters.A + [_card effectValueWithType:EffectTypeA];
    NSInteger valueS = _parameters.S + [_card effectValueWithType:EffectTypeS];
    return _baseSwordRange + (NSUInteger)((CGFloat)_baseSwordRange * (0.1f * ((CGFloat)(valueA < 0 ? 0 : valueA) + (CGFloat)(valueS < 0 ? 0 : valueS)))) + [_card effectValueWithType:EffectTypeSwordRange];
}

- (NSUInteger)bowRange {
    NSInteger valueA = _parameters.A + [_card effectValueWithType:EffectTypeA];
    NSInteger valueE = _parameters.E + [_card effectValueWithType:EffectTypeE];
    return _baseBowRange + (NSUInteger)((CGFloat)_baseBowRange * (0.1f * ((CGFloat)(valueA < 0 ? 0 : valueA) + (CGFloat)(valueE < 0 ? 0 : valueE)))) + [_card effectValueWithType:EffectTypeBowRange];
}

- (NSDictionary *)dictionary {
    return @{S_KEY : @(_parameters.S),
             E_KEY : @(_parameters.E),
             A_KEY : @(_parameters.A),
             L_KEY : @(_parameters.L),
             CARD_IDENTIFIER_KEY : _card.identifier};
}

@end
