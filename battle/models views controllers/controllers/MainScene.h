//
//  MainScene.h
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>


typedef NS_ENUM(NSUInteger, MSPlayer) {
    MSPlayerA = 0,
    MSPlayerB
};

CG_INLINE MSPlayer MSPlayerOtherPlayer(MSPlayer player) {
    return player == MSPlayerA ? MSPlayerB : MSPlayerA;
}


typedef NS_ENUM(NSUInteger, MSDirection) {
    MSDirectionUp = 0,
    MSDirectionRight,
    MSDirectionDown,
    MSDirectionLeft
};


typedef NS_ENUM(NSUInteger, MSAttackType) {
    MSAttackTypeSword = 0,
    MSAttackTypeBow
};


typedef NS_ENUM(NSUInteger, MSItem) {
    MSItemNone = 0,
    MSItemHealthPoints,
    MSItemMovePoints
};


@class MainScene;


@protocol MainSceneDelegate <SKSceneDelegate>

@optional

- (void)mainScene:(MainScene *)scene didPickUpItem:(MSItem)item withValue:(NSUInteger)value;

- (void)didToggleCameraCompleteWithMainScene:(MainScene *)scene;

@end


@interface MainScene : SKScene

@property (assign, nonatomic) NSUInteger zoomLevel;

- (void)zoomIn;
- (void)zoomOut;

- (void)nextZoomLevel;

- (void)toggleCameraToPlayer:(MSPlayer)player;

- (void)toggleCameraToPlayer:(MSPlayer)player animated:(BOOL)animated;

- (BOOL)movePlayer:(MSPlayer)player withDirection:(MSDirection)direction;

- (void)synchronizePlayer:(MSPlayer)player withDirection:(MSDirection)direction;

- (BOOL)drawGridCellsWithPlayer:(MSPlayer)player andRange:(NSUInteger)range;

- (void)attackPlayer:(MSPlayer)attackedPlayer withAttackType:(MSAttackType)attackType andDamage:(NSUInteger)damage asCritical:(BOOL)critical;

- (void)deathWithPlayer:(MSPlayer)player;

@end
