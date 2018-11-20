//
//  GameViewController.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "GameViewController.h"

#import "Timer.h"

#import "MainScene.h"

#import "GamePadViewController.h"


#define TURN_TIME  (60)

#define SCENE_NAME              (@"MainScene")
#define DEFAULT_CARD_IDENTIFIER (@"")


typedef NS_ENUM(NSUInteger, GVCTurnPlayer) {
    GVCTurnPlayerA = 0,
    GVCTurnPlayerB
};

CG_INLINE BOOL GVCTurnIsPlayerA (GVCTurnPlayer turnPlayer) {
    return turnPlayer == GVCTurnPlayerA;
}

CG_INLINE GVCTurnPlayer GVCTurnPlayerMakeReverse (GVCTurnPlayer turnPlayer) {
    return GVCTurnIsPlayerA(turnPlayer) ? GVCTurnPlayerB : GVCTurnPlayerA;
}


@interface GameViewController () <PlayerDelegate, TimerDelegate, GamePadViewControllerDelegate, MainSceneDelegate>

{
    
    BOOL canAttackWithSword;
    BOOL canAttackWithBow;
    
}

@property (weak, nonatomic) IBOutlet SKView *sceneView;

@property (weak, nonatomic) IBOutlet UILabel *healthPointsPlayerALabel;
@property (weak, nonatomic) IBOutlet UILabel *healthPointsPlayerBLabel;

@property (weak, nonatomic) IBOutlet UILabel *turnTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *movePointsLabel;

@property (weak, nonatomic) IBOutlet UIImageView *topLineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLineImageView;

@property (weak, nonatomic) IBOutlet UIImageView *arrowAImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowBImageView;

@property (weak, nonatomic) IBOutlet UIView *gamePadViewContainer;

@property (assign, nonatomic) GVCTurnPlayer turn;

@property (assign, nonatomic) MSPlayer currentScenePlayer;
@property (assign, nonatomic) MSPlayer waitingScenePlayer;

@property (strong, nonatomic, readonly) Player *playerA;
@property (strong, nonatomic, readonly) Player *playerB;

@property (strong, nonatomic) Player *currentPlayer;
@property (strong, nonatomic) Player *waitingPlayer;

@property (strong, nonatomic) Timer *timer;

@property (strong, nonatomic) MainScene *mainScene;

@property (strong, nonatomic) GamePadViewController *gamePadViewController;

@end


@implementation GameViewController

#pragma mark - Initialization methods

- (instancetype)initWithPlayerA:(Player *)playerA andPlayerB:(Player *)playerB {
    self = [super init];
    if (self) {
        _playerA = playerA;
        _playerB = playerB;
    }
    return self;
}

#pragma mark - Overriding methods

- (void)viewDidLoad {
    [super viewDidLoad];
    Parameters  parameters = ParametersMake(5, 5, 5, 5);
    Card       *card       = [[CardsManager shared] cardWithIdentifier:DEFAULT_CARD_IDENTIFIER];
    if (!_playerA) {
        _playerA = [[Player alloc] initWithParametrs:parameters andCard:card];
    }
    if (!_playerB) {
        _playerB = [[Player alloc] initWithParametrs:parameters andCard:card];
    }
    _turn               = GVCTurnPlayerA;
    _mainScene          = [MainScene nodeWithFileNamed:SCENE_NAME];
    _timer              = [Timer new];
    _mainScene.delegate = self;
    _timer.delegate     = self;
    _playerA.delegate   = self;
    _playerB.delegate   = self;
    [_sceneView presentScene:_mainScene];
    [_playerA reset];
    [_playerB reset];
    UIEdgeInsets edgeInsets           = UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f);
    _topLineImageView.image           = [_topLineImageView.image resizableImageWithCapInsets:edgeInsets];
    _bottomLineImageView.image        = [_bottomLineImageView.image resizableImageWithCapInsets:edgeInsets];
    _gamePadViewController            = [GamePadViewController shared];
    _gamePadViewController.on         = NO;
    _gamePadViewController.delegate   = self;
    _gamePadViewController.parentView = _gamePadViewContainer;
    [self.view layoutIfNeeded];
    [self updatePlayersUI];
    [self updateTurnUI];
    [self updateTurnTimeUIWithTime:TURN_TIME];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_mainScene toggleCameraToPlayer:self.currentScenePlayer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_gamePadViewController updateViewLayout];
}

#pragma mark - Private methods

- (void)updatePlayersUI {
    _healthPointsPlayerALabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)_playerA.healthPoints];
    _healthPointsPlayerBLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)_playerB.healthPoints];
    _movePointsLabel.text          = [NSString stringWithFormat:@"%ld", (unsigned long)self.currentPlayer.movePoints];
}

- (void)updateTurnUI {
    BOOL condition          = GVCTurnIsPlayerA(_turn);
    _arrowAImageView.hidden = !condition;
    _arrowBImageView.hidden =  condition;
}

- (void)updateTurnTimeUIWithTime:(NSUInteger)time {
    _turnTimeLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)time];
}

- (MSPlayer)scenePlayerWithPlayer:(Player *)player {
    return player == _playerA ? MSPlayerA : MSPlayerB;
}

- (void)movePlayerWithDirection:(MSDirection)direction {
    Player *player = self.currentPlayer;
    if (player.canMakeMove) {
        if ([_mainScene movePlayer:self.currentScenePlayer withDirection:direction]) {
            [player makeMove];
            [self updatePlayersUI];
        }
    }
}

- (BOOL)drawGridCellsWithAttackType:(MSAttackType)attackType {
    NSUInteger range;
    switch (attackType) {
        case MSAttackTypeSword:
            range = self.currentPlayer.swordRange;
            break;
        case MSAttackTypeBow:
            range = self.currentPlayer.bowRange;
            break;
    }
    return [_mainScene drawGridCellsWithPlayer:self.currentScenePlayer andRange:range];
}

- (void)attackPlayerWithAttackType:(MSAttackType)attackType {
    NSUInteger  damage   = 0;
    BOOL        critical = NO;
    switch (attackType) {
        case MSAttackTypeSword: {
            if (!self.currentPlayer.canMakeAttackSword) {
                return;
            }
            damage = [self.currentPlayer swordDamageAsCrititcal:&critical];
        }
            break;
        case MSAttackTypeBow:
            if (!self.currentPlayer.canMakeAttackBow) {
                return;
            }
            damage = [self.currentPlayer bowDamageAsCrititcal:&critical];
            break;
    }
    [self.waitingPlayer addDamage:damage];
    [_mainScene attackPlayer:self.waitingScenePlayer withAttackType:attackType andDamage:damage asCritical:critical];
}

- (void)endTurn {
    [_timer stop];
    Player *player = self.waitingPlayer;
    [player resetMovePoints];
    [player resetAttacks];
    _turn = GVCTurnPlayerMakeReverse(_turn);
    _gamePadViewController.on = NO;
    [self updatePlayersUI];
    [self updateTurnUI];
    [self updateTurnTimeUIWithTime:TURN_TIME];
    [_mainScene toggleCameraToPlayer:self.currentScenePlayer];
#warning
}

#pragma mark - Private properties

- (MSPlayer)currentScenePlayer {
    return [self scenePlayerWithPlayer:self.currentPlayer];
}

- (MSPlayer)waitingScenePlayer {
    return [self scenePlayerWithPlayer:self.waitingPlayer];
}

- (Player *)currentPlayer {
    return GVCTurnIsPlayerA(_turn) ? _playerA : _playerB;
}

- (Player *)waitingPlayer {
    return GVCTurnIsPlayerA(_turn) ? _playerB : _playerA;
}

#pragma mark - PlayerDelegate

- (void)didEndHealthPointsWithPlayer:(Player *)player {
    [_mainScene deathWithPlayer:[self scenePlayerWithPlayer:player]];
}

- (void)didReceiveDamageWithPlayer:(Player *)player {
    [self updatePlayersUI];
}

- (void)didReceiveHealthPointsWithPlayer:(Player *)player {
    [self updatePlayersUI];
}

- (void)didReceiveMovePointsWithPlayer:(Player *)player {
    [self updatePlayersUI];
}

- (void)didEndMovePointsWithPlayer:(Player *)player {
    // Empty...
}

- (void)didEndAttacksWithPlayer:(Player *)player {
    // Empty...
}

- (void)didEndTurnWithPlayer:(Player *)player {
    // Empty...
}

#pragma mark - TimerDelegate

- (void)timer:(Timer *)timer didUpdateTime:(NSUInteger)time {
    [self updateTurnTimeUIWithTime:time];
}

- (void)didCompleteCountdownWithTimer:(Timer *)timer {
    [self endTurn];
}

#pragma mark - GamePadViewControllerDelegate

- (void)gamePadViewController:(GamePadViewController *)viewController didPressActionButton:(GPVCActionButton)actionButton {
    switch (actionButton) {
        case GPVCActionButtonA:
            if (canAttackWithSword) {
                canAttackWithSword = NO;
                [self attackPlayerWithAttackType:MSAttackTypeSword];
            } else {
                canAttackWithSword = [self drawGridCellsWithAttackType:MSAttackTypeSword];
            }
            break;
        case GPVCActionButtonB:
            if (canAttackWithBow) {
                canAttackWithBow = NO;
                [self attackPlayerWithAttackType:MSAttackTypeBow];
            } else {
                canAttackWithSword = [self drawGridCellsWithAttackType:MSAttackTypeBow];
            }
            break;
        case GPVCActionButtonC:
            [self endTurn];
            break;
        case GPVCActionButtonD:
            [_mainScene nextZoomLevel];
            break;
    }
}

- (void)gamePadViewController:(GamePadViewController *)viewController didPressDirectionButton:(GPVCDirectionButton)directionButton {
    switch (directionButton) {
        case GPVCDirectionButtonUp:
            [self movePlayerWithDirection:MSDirectionUp];
            break;
        case GPVCDirectionButtonRight:
            [self movePlayerWithDirection:MSDirectionRight];
            break;
        case GPVCDirectionButtonDown:
            [self movePlayerWithDirection:MSDirectionDown];
            break;
        case GPVCDirectionButtonLeft:
            [self movePlayerWithDirection:MSDirectionLeft];
            break;
    }
}

- (void)didPressMenuWithGamePadViewController:(GamePadViewController *)viewController {
#warning
}

- (void)didPressInfoWithGamePadViewController:(GamePadViewController *)viewController {
#warning
}

#pragma mark - MainSceneDelegate

- (void)mainScene:(MainScene *)scene didPickUpItem:(MSItem)item withValue:(NSUInteger)value {
    switch (item) {
        case MSItemNone:
            break;
        case MSItemHealthPoints:
            [self.currentPlayer addHealthPoints:value];
            break;
        case MSItemMovePoints:
            [self.currentPlayer addMovePoints:value];
            break;
    }
}

- (void)didToggleCameraCompleteWithMainScene:(MainScene *)scene {
    _gamePadViewController.on = YES;
    [_timer startCountdownFromTime:TURN_TIME];
}

@end
