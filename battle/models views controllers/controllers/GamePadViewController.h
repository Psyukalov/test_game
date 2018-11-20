//
//  GamePadViewController.h
//  battle
//
//  Created by Vladimir Psyukalov on 19.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, GPVCActionButton) {
    GPVCActionButtonA = 0,
    GPVCActionButtonB,
    GPVCActionButtonC,
    GPVCActionButtonD
};


typedef NS_ENUM(NSUInteger, GPVCDirectionButton) {
    GPVCDirectionButtonUp = 0,
    GPVCDirectionButtonRight,
    GPVCDirectionButtonDown,
    GPVCDirectionButtonLeft
};


@class GamePadViewController;


@protocol GamePadViewControllerDelegate <NSObject>

@optional

- (void)gamePadViewController:(GamePadViewController *)viewController didPressActionButton:(GPVCActionButton)actionButton;

- (void)gamePadViewController:(GamePadViewController *)viewController didPressDirectionButton:(GPVCDirectionButton)directionButton;

- (void)didPressMenuWithGamePadViewController:(GamePadViewController *)viewController;

- (void)didPressInfoWithGamePadViewController:(GamePadViewController *)viewController;

@end


@interface GamePadViewController : UIViewController

@property (weak, nonatomic) id<GamePadViewControllerDelegate> delegate;

@property (assign, nonatomic) BOOL on;

@property (strong, nonatomic) UIView *parentView;

+ (instancetype)shared;

- (void)updateViewLayout;

@end
