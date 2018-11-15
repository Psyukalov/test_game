//
//  Card.h
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "Effect.h"


@interface Card : NSObject

@property (strong, nonatomic, readonly) NSString *identifier;

@property (strong, nonatomic, readonly) NSArray<Effect *> *effects;

@property (strong, nonatomic, readonly) NSString *name;

@property (strong, nonatomic, readonly) NSString *text;

- (instancetype)initWithIdentifier:(NSString *)identifier andEffects:(NSArray<Effect *> *)effects;

- (NSUInteger)effectValueWithType:(EffectType)type;

@end
