//
//  GameViewController.h
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "Player.h"


@interface GameViewController : UIViewController

- (instancetype)initWithPlayerA:(Player *)playerA andPlayerB:(Player *)playerB;

@end
