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


#define TURN_TIME  (60)
#define TURN_DELAY (2)

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


@interface GameViewController () <PlayerDelegate, TimerDelegate>

@property (weak, nonatomic) IBOutlet SKView *sceneView;

@property (weak, nonatomic) IBOutlet UIImageView *topLineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLineImageView;

@property (assign, nonatomic) GVCTurnPlayer turn;

@property (assign, nonatomic) MSPlayer currentScenePlayer;
@property (assign, nonatomic) MSPlayer waitingScenePlayer;

@property (strong, nonatomic, readonly) Player *playerA;
@property (strong, nonatomic, readonly) Player *playerB;

@property (strong, nonatomic) Player *currentPlayer;
@property (strong, nonatomic) Player *waitingPlayer;

@property (strong, nonatomic) Timer *timer;

@property (strong, nonatomic) MainScene *mainScene;

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
    _turn             = GVCTurnPlayerA;
    _mainScene        = [MainScene nodeWithFileNamed:SCENE_NAME];
    _timer            = [Timer new];
    _timer.delegate   = self;
    _playerA.delegate = self;
    _playerB.delegate = self;
    [_sceneView presentScene:_mainScene];
    [_playerA reset];
    [_playerB reset];
    [_mainScene toggleCameraToPlayer:self.currentScenePlayer animated:NO];
    UIEdgeInsets edgeInsets    = UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f);
    _topLineImageView.image    = [_topLineImageView.image resizableImageWithCapInsets:edgeInsets];
    _bottomLineImageView.image = [_bottomLineImageView.image resizableImageWithCapInsets:edgeInsets];
}

#pragma mark - Private methods

- (MSPlayer)scenePlayerWithPlayer:(Player *)player {
    return player == _playerA ? MSPlayerA : MSPlayerB;
}

- (void)movePlayerWithDirection:(MSDirection)direction {
    if ([self.currentPlayer makeMove]) {
        [_mainScene movePlayer:self.currentScenePlayer withDirection:direction];
    }
}

- (void)drawGridCellsWithAttackType:(MSAttackType)attackType {
    NSUInteger range;
    switch (attackType) {
        case MSAttackTypeSword:
            range = self.currentPlayer.swordRange;
            break;
        case MSAttackTypeBow:
            range = self.currentPlayer.bowRange;
            break;
    }
    [_mainScene drawGridCellsWithPlayer:self.currentScenePlayer andRange:range];
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

#pragma mark - Public methods

- (void)movePlayerUp {
    [self movePlayerWithDirection:MSDirectionUp];
}

- (void)movePlayerRight {
    [self movePlayerWithDirection:MSDirectionRight];
}

- (void)movePlayerDown {
    [self movePlayerWithDirection:MSDirectionDown];
}

- (void)movePlayerLeft {
    [self movePlayerWithDirection:MSDirectionLeft];
}

- (void)drawGridCellsWithSword {
    [self drawGridCellsWithAttackType:MSAttackTypeSword];
}

- (void)drawGridCellsWithBow {
    [self drawGridCellsWithAttackType:MSAttackTypeBow];
}

- (void)attackPlayerWithSword {
    [self attackPlayerWithAttackType:MSAttackTypeSword];
}

- (void)attackPlayerWithBow {
    [self attackPlayerWithAttackType:MSAttackTypeBow];
}

- (void)endTurn {
    _turn = GVCTurnPlayerMakeReverse(_turn);
    [_mainScene toggleCameraToPlayer:self.currentScenePlayer];
#warning
}

#pragma mark - PlayerDelegate

- (void)didEndHealthPointsWithPlayer:(Player *)player {
    [_mainScene deathWithPlayer:[self scenePlayerWithPlayer:player]];
}

- (void)didReceiveDamageWithPlayer:(Player *)player {
#warning
}

- (void)didEndMovePointsWithPlayer:(Player *)player {
#warning
}

- (void)didEndAttacksWithPlayer:(Player *)player {
#warning
}

- (void)didEndTurnWithPlayer:(Player *)player {
    [self performSelector:@selector(endTurn) withObject:nil afterDelay:TURN_DELAY];
}

#pragma mark - TimerDelegate

- (void)timer:(Timer *)timer didUpdateTime:(NSUInteger)time {
#warning
}

- (void)didCompleteCountdownWithTimer:(Timer *)timer {
    [self endTurn];
}

#pragma mark - Actions

- (IBAction)test:(id)sender {
    //    [self drawGridCellsWithBow];
    [_mainScene zoomIn];
}

- (IBAction)test2:(id)sender {
    //    [self drawGridCellsWithSword];
    //    [_mainScene zoomOut];
    [self endTurn];
}
#warning

@end
