//
//  CardsManager.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "CardsManager.h"


@implementation CardsManager

#pragma mark - Public static methods

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

#pragma mark - Initialization methods

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Private methods

- (void)setup {
    _cards = nil;
    Card *card_01 = [[Card alloc] initWithIdentifier:@"card_01" andEffects:@[[[Effect alloc] initWithType:EffectTypeHealthPoints andValue:-50],
                                                                             [[Effect alloc] initWithType:EffectTypeBowCountAttack andValue:2]]];
    _cards = @[card_01];
}

#pragma mark - Public methods

- (Card *)cardWithIdentifier:(NSString *)identifier {
    for (Card *card in _cards) {
        if ([card.identifier isEqualToString:identifier]) {
            return card;
        }
    }
    return nil;
}

@end
