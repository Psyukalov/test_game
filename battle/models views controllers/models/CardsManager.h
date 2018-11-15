//
//  CardsManager.h
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "Card.h"


@interface CardsManager : NSObject

@property (strong, nonatomic, readonly) NSArray<Card *> *cards;

+ (instancetype)shared;

- (Card *)cardWithIdentifier:(NSString *)identifier;

@end
