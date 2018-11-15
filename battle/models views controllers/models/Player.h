//
//  Player.h
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "CardsManager.h"


typedef struct Parameters {
    NSUInteger S;
    NSUInteger E;
    NSUInteger A;
    NSUInteger L;
} Parameters;

CG_INLINE Parameters ParametersMake(NSUInteger S, NSUInteger E, NSUInteger A, NSUInteger L) {
    Parameters parameters;
    parameters.S = S;
    parameters.E = E;
    parameters.A = A;
    parameters.L = L;
    return parameters;
}


@class Player;


@protocol PlayerDelegate <NSObject>

@optional

- (void)didEndHealthPointsWithPlayer:(Player *)player;

- (void)didReceiveDamageWithPlayer:(Player *)player;

- (void)didEndMovePointsWithPlayer:(Player *)player;

- (void)didEndAttacksWithPlayer:(Player *)player;

- (void)didEndTurnWithPlayer:(Player *)player;

@end


@interface Player : NSObject

@property (weak, nonatomic) id<PlayerDelegate> delegate;

@property (assign, nonatomic) BOOL canMakeAttackSword;
@property (assign, nonatomic) BOOL canMakeAttackBow;

@property (assign, nonatomic, readonly) Parameters parameters;

@property (strong, nonatomic, readonly) Card *card;

@property (assign, nonatomic, readonly) NSInteger healthPoints;

@property (assign, nonatomic, readonly) NSInteger movePoints;

@property (assign, nonatomic, readonly) NSUInteger maxHealthPoints;

@property (assign, nonatomic, readonly) NSUInteger maxMovePoints;

@property (assign, nonatomic, readonly) NSUInteger swordRange;

@property (assign, nonatomic, readonly) NSUInteger bowRange;

@property (strong, nonatomic, readonly) NSDictionary *dictionary;

- (instancetype)initWithParametrs:(Parameters)parameters andCard:(Card *)card;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)resetHealthPoints;

- (void)resetMovePoints;

- (void)resetAttacks;

- (void)reset;

- (NSUInteger)swordDamageAsCrititcal:(BOOL *)critical;

- (NSUInteger)bowDamageAsCrititcal:(BOOL *)critical;

- (void)addDamage:(NSUInteger)damage;

- (BOOL)makeMove;

@end
