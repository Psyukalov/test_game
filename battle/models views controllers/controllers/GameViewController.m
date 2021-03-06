//
//  GameViewController.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "GameViewController.h"

#import "Macros.h"

#import "UIView+Localizable.h"

#import "Timer.h"

#import "MainScene.h"

#import "GamePadViewController.h"

#import "GameMenuToggleView.h"


#define TURN_TIME  (60)

#define SCENE_NAME (@"MainScene")


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


@interface GameViewController () <PlayerDelegate, TimerDelegate, GamePadViewControllerDelegate, MainSceneDelegate, ToggleViewDelegate>

@property (weak, nonatomic) IBOutlet SKView *sceneView;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UILabel *healthPointsPlayerALabel;
@property (weak, nonatomic) IBOutlet UILabel *healthPointsPlayerBLabel;

@property (weak, nonatomic) IBOutlet UILabel *turnTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *movePointsLabel;

@property (weak, nonatomic) IBOutlet UILabel *swordAttackCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *bowAttackCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *topLineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLineImageView;

@property (weak, nonatomic) IBOutlet UIImageView *arrowAImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowBImageView;

@property (weak, nonatomic) IBOutlet UIImageView *arrowSwordImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowBowImageView;

@property (weak, nonatomic) IBOutlet UIView *gamePadViewContainer;

@property (weak, nonatomic) IBOutlet GameMenuToggleView *gameMenuToggleView;

@property (weak, nonatomic) IBOutlet UIView *turnView;

@property (weak, nonatomic) IBOutlet ToggleView *endGameToggleView;

@property (weak, nonatomic) IBOutlet UILabel *continueLabel;
@property (weak, nonatomic) IBOutlet UILabel *exitLabelA;

@property (weak, nonatomic) IBOutlet UILabel *turnLabel;

@property (weak, nonatomic) IBOutlet UILabel *endGameLabel;

@property (weak, nonatomic) IBOutlet UILabel *playAgainLabel;
@property (weak, nonatomic) IBOutlet UILabel *exitLabelB;

@property (assign, nonatomic) GVCTurnPlayer turn;

@property (assign, nonatomic) MSPlayer currentScenePlayer;
@property (assign, nonatomic) MSPlayer waitingScenePlayer;

@property (assign, nonatomic, readonly) MSAttackType currentAttackType;

@property (assign, nonatomic) MSAttackType attackTypePlayerA;
@property (assign, nonatomic) MSAttackType attackTypePlayerB;

@property (strong, nonatomic, readonly) Player *playerA;
@property (strong, nonatomic, readonly) Player *playerB;

@property (strong, nonatomic) Player *currentPlayer;
@property (strong, nonatomic) Player *waitingPlayer;

@property (strong, nonatomic) Timer *timer;

@property (strong, nonatomic) MainScene *mainScene;

@property (strong, nonatomic) GamePadViewController *gamePadViewController;

@property (assign, nonatomic) BOOL neededChangeAttackType;

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
    //    Parameters parameters = ParametersMake(<#NSUInteger S#>, <#NSUInteger E#>, <#NSUInteger A#>, <#NSUInteger L#>)
    if (!_playerA) {
        _playerA = [[Player alloc] initWithParametrs:ParametersMake(10, 8, 1, 1) andCard:nil];
    }
    if (!_playerB) {
        _playerB = [[Player alloc] initWithParametrs:ParametersMake(1, 1, 8, 10) andCard:[[Card alloc] initWithIdentifier:@"01" andEffects:@[[[Effect alloc] initWithType:EffectTypeL andValue:5]/*,
                                                                                                                                                                                                  [[Effect alloc] initWithType:EffectTypeHealthPoints andValue:-60]*/]]];
    }
    _turn               = (GVCTurnPlayer)arc4random_uniform(2);
    _attackTypePlayerA  = MSAttackTypeSword;
    _attackTypePlayerB  = MSAttackTypeSword;
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
    [_gameMenuToggleView addItemLabel:_continueLabel];
    [_gameMenuToggleView addItemLabel:_exitLabelA];
    [_endGameToggleView addItemLabel:_playAgainLabel];
    [_endGameToggleView addItemLabel:_exitLabelB];
    _gameMenuToggleView.delegate         = self;
    _endGameToggleView.delegate          = self;
    _gameMenuToggleView.currentItemIndex = 0;
    _endGameToggleView.currentItemIndex  = 0;
    _gameMenuToggleView.hidden           = YES;
    _endGameToggleView.hidden            = YES;
    [_turnView localizable];
    [_headerView localizable];
    [_gameMenuToggleView localizable];
    [_endGameToggleView localizable];
    [self updateUI];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_mainScene toggleCameraToPlayer:self.currentScenePlayer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _gamePadViewController.parentView = nil;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_gamePadViewController updateViewLayout];
}

#pragma mark - Private methods

- (void)updateUI {
    [self updatePlayersUI];
    [self updateTurnUI];
    [self updateTurnTimeUIWithTime:TURN_TIME];
    [self updateAttackTypeUI];
}

- (void)updatePlayersUI {
    _healthPointsPlayerALabel.text = [NSString stringWithFormat:@"%03ld", (unsigned long)_playerA.healthPoints];
    _healthPointsPlayerBLabel.text = [NSString stringWithFormat:@"%03ld", (unsigned long)_playerB.healthPoints];
    _movePointsLabel.text          = [NSString stringWithFormat:@"%02ld", (unsigned long)self.currentPlayer.movePoints];
}

- (void)updateTurnUI {
    BOOL condition          = GVCTurnIsPlayerA(_turn);
    _arrowAImageView.hidden = !condition;
    _arrowBImageView.hidden =  condition;
    NSString *key           =  GVCTurnIsPlayerA(_turn) ? @"gvc_l_player_a" : @"gvc_l_player_b";
    _turnLabel.text         =  [NSString stringWithFormat:@"%@ %@", LOCALIZE(@"gvc_l_turn"), LOCALIZE(key)];
}

- (void)updateTurnTimeUIWithTime:(NSUInteger)time {
    _turnTimeLabel.text = [NSString stringWithFormat:@"%02ld", (unsigned long)time];
}

- (void)updateAttackTypeUI {
    BOOL condition = self.currentAttackType == MSAttackTypeSword;
    _arrowSwordImageView.hidden = !condition;
    _arrowBowImageView.hidden   =  condition;
    _swordAttackCountLabel.text =  [NSString stringWithFormat:@"%02ld", (unsigned long)self.currentPlayer.countAttackSword];
    _bowAttackCountLabel.text   =  [NSString stringWithFormat:@"%02ld", (unsigned long)self.currentPlayer.countAttackBow];
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
            _neededChangeAttackType = NO;
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
    [self updateAttackTypeUI];
    return [_mainScene checkEnemyForPlayer:self.currentScenePlayer withRange:range];
}

- (void)attackPlayerWithAttackType:(MSAttackType)attackType {
    NSUInteger  range    = 0;
    NSUInteger  damage   = 0;
    BOOL        critical = NO;
    switch (attackType) {
        case MSAttackTypeSword: {
            if (!self.currentPlayer.canMakeAttackSword) {
                return;
            }
            range  = self.currentPlayer.swordRange;
            damage = [self.currentPlayer swordDamageAsCrititcal:&critical];
        }
            break;
        case MSAttackTypeBow:
            if (!self.currentPlayer.canMakeAttackBow) {
                return;
            }
            range  = self.currentPlayer.bowRange;
            damage = [self.currentPlayer bowDamageAsCrititcal:&critical];
            break;
    }
    BOOL hasEnemy = [_mainScene checkEnemyForPlayer:self.currentScenePlayer withRange:range andNeededDrawGridCells:NO];
    if (!hasEnemy) {
        return;
    }
    switch (attackType) {
        case MSAttackTypeSword:
            [self.currentPlayer makeAttackSword];
            break;
        case MSAttackTypeBow:
            [self.currentPlayer makeAttackBow];
            break;
    }
    [_mainScene attackPlayer:self.waitingScenePlayer withAttackType:attackType andDamage:damage asCritical:critical completion:^{
        [self updateAttackTypeUI];
        [self.waitingPlayer addDamage:damage];
    }];
    _neededChangeAttackType = NO;
}

- (void)endTurn {
    [_timer stop];
    Player *player = self.waitingPlayer;
    [player resetMovePoints];
    [player resetAttacks];
    _turn = GVCTurnPlayerMakeReverse(_turn);
    _gamePadViewController.on = NO;
    _neededChangeAttackType   = NO;
    _turnView.hidden          = NO;
    [self updateUI];
    [_mainScene toggleCameraToPlayer:self.currentScenePlayer];
#warning
}

- (void)endGame {
    [_timer stop];
    [GamePadViewController shared].delegate = _endGameToggleView;
    _endGameToggleView.currentItemIndex = 0;
    _endGameToggleView.hidden           = NO;
    NSString *key      =  _playerA.healthPoints == 0 ? @"gvc_l_player_b" : @"gvc_l_player_a";
    _endGameLabel.text = [NSString stringWithFormat:@"%@ %@", LOCALIZE(@"gvc_l_game_end"), LOCALIZE(key)];
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

- (MSAttackType)currentAttackType {
    return GVCTurnIsPlayerA(_turn) ? _attackTypePlayerA : _attackTypePlayerB;
}

#pragma mark - PlayerDelegate

- (void)didEndHealthPointsWithPlayer:(Player *)player {
    [_mainScene deathWithPlayer:[self scenePlayerWithPlayer:player]];
#warning
    [self endGame];
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
    [self endTurn];
}

- (void)didReceiveCountsAttackWithPlayer:(Player *)player {
    [self updateAttackTypeUI];
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
        case GPVCActionButtonA: {
            [self attackPlayerWithAttackType:self.currentAttackType];
        }
            break;
        case GPVCActionButtonB: {
            BOOL canAttack;
            switch (self.currentAttackType) {
                case MSAttackTypeSword:
                    canAttack = self.currentPlayer.canMakeAttackSword;
                    break;
                case MSAttackTypeBow:
                    canAttack = self.currentPlayer.canMakeAttackBow;
                    break;
            }
            if (_neededChangeAttackType || !canAttack) {
                if (GVCTurnIsPlayerA(_turn)) {
                    _attackTypePlayerA = _attackTypePlayerA == MSAttackTypeSword ? MSAttackTypeBow : MSAttackTypeSword;
                } else {
                    _attackTypePlayerB = _attackTypePlayerB == MSAttackTypeSword ? MSAttackTypeBow : MSAttackTypeSword;
                }
            }
            _neededChangeAttackType = YES;
            [self drawGridCellsWithAttackType:self.currentAttackType];
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
    [GamePadViewController shared].delegate = _gameMenuToggleView;
    _gameMenuToggleView.hidden = NO;
    [_timer pause];
}

- (void)didPressInfoWithGamePadViewController:(GamePadViewController *)viewController {
#warning
}

#pragma mark - MainSceneDelegate

- (void)mainScene:(MainScene *)scene didPickUpItem:(MSItem)item withValue:(NSInteger)value {
    switch (item) {
        case MSItemNone:
            break;
        case MSItemHealthPoints:
            [self.currentPlayer addHealthPoints:value];
            break;
        case MSItemMovePoints:
            [self.currentPlayer addMovePoints:value];
            break;
        case MSItemCountAttackSword:
            [self.currentPlayer addCountAttackSword:value];
            break;
        case MSItemCountAttackBow:
            [self.currentPlayer addCountAttackBow:value];
            break;
    }
}

- (void)didToggleCameraCompleteWithMainScene:(MainScene *)scene {
    _gamePadViewController.on = YES;
    _turnView.hidden          = YES;
    [_timer startCountdownFromTime:TURN_TIME];
}

#pragma mark - ToggleViewDelegate

- (void)toggleView:(ToggleView *)view didSelectItemLabelWithIndex:(NSUInteger)index {
    if (view == _gameMenuToggleView) {
        switch (index) {
            case 0: {
                [GamePadViewController shared].delegate = self;
                _gameMenuToggleView.hidden = YES;
                [_timer start];
            }
                break;
            case 1: {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
                break;
            default:
                break;
        }
    } else if (view == _endGameToggleView) {
        switch (index) {
            case 0: {
                [GamePadViewController shared].delegate = self;
                _endGameToggleView.hidden = YES;
#warning
            }
                break;
            case 1: {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
                break;
            default:
                break;
        }
    }
}

@end
