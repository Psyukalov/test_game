//
//  GameMenuToggleView.m
//  battle
//
//  Created by Vladimir Psyukalov on 20.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "GameMenuToggleView.h"


#define CONTINUE_INDEX (0)


@implementation GameMenuToggleView

#pragma mark - Overriding methods

- (void)gamePadViewController:(GamePadViewController *)viewController didPressActionButton:(GPVCActionButton)actionButton {
    switch (actionButton) {
        case GPVCActionButtonA: {
            [super gamePadViewController:viewController didPressActionButton:actionButton];
        }
            break;
        case GPVCActionButtonB: {
            [self close];
        }
            break;
        default:
            break;
    }
}

- (void)didPressMenuWithGamePadViewController:(GamePadViewController *)viewController {
    [super didPressMenuWithGamePadViewController:viewController];
    [self close];
}

#pragma mark - Private methods

- (void)close {
    self.currentItemIndex = CONTINUE_INDEX;
    [self selectWithCurrentItemIndex];
}

@end
