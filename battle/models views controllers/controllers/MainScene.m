//
//  MainScene.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "MainScene.h"

#define FREE_X             (1)
#define FREE_Y             (2)
#define MIN_ZOOM_LEVEL     (1)
#define MAX_ZOOM_LEVEL     (3)
#define DEFAULT_ZOOM_LEVEL (1)

#define GRID_SIZE       (32.0f)
#define MOVE_DURATION   (0.32f)
#define CAMERA_DURATION (1.28f)
#define ZOOM_DURATION   (0.64f)

#define NO_MOVE_ZONE_USER_DATA_KEY   (@"no_move_zone_user_data_key")
#define PLAYER_USER_DATA_KEY         (@"player_user_data_key")

#define PLAYER_A_SPRITE_NODE         (@"player_a_sprite_node")
#define PLAYER_B_SPRITE_NODE         (@"player_b_sprite_node")
#define CAMER_NODE                   (@"camera_node")
#define TILE_MAP_NODE                (@"tile_map_node")

#define GRID_CELL_EMPTY_SPRITE_NAME  (@"grid_cell_empty_sprite")
#define GRID_CELL_PLAYER_SPRITE_NAME (@"grid_cell_player_sprite")
#define SWORD_ATTACK_SPRITE_NAME     (@"sword_attack_sprite")
#define BOW_ATTACK_SPRITE_NAME       (@"bow_attack_sprite")


typedef NS_ENUM(NSUInteger, MSCellStatus) {
    MSCellStatusEmpty = 0,
    MSCellStatusNoMoveZone,
    MSCellStatusHasPlayer
};


CG_INLINE BOOL MSCellStatusCanMove(MSCellStatus cellStatus) {
    return cellStatus == MSCellStatusEmpty;
}


@interface MainScene ()

@property (strong, nonatomic) SKSpriteNode *playerA;
@property (strong, nonatomic) SKSpriteNode *playerB;

@property (strong, nonatomic) SKCameraNode *cameraNode;

@property (strong, nonatomic) NSMutableArray<SKSpriteNode *> *gridCellSpriteNodes;

@end


@implementation MainScene

#pragma mark - Overriding methods

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    _zoomLevel           = DEFAULT_ZOOM_LEVEL;
    _playerA             = (SKSpriteNode *)[self childNodeWithName:PLAYER_A_SPRITE_NODE];
    _playerB             = (SKSpriteNode *)[self childNodeWithName:PLAYER_B_SPRITE_NODE];
    _cameraNode          = (SKCameraNode *)[self childNodeWithName:CAMER_NODE];
    _gridCellSpriteNodes = [NSMutableArray new];
    [self setupNoMoveZoneWithTileMapNode:(SKTileMapNode *)[self childNodeWithName:TILE_MAP_NODE]];
}

#pragma mark - Public methods

- (void)zoomIn {
    self.zoomLevel = _zoomLevel - 1;
}

- (void)zoomOut {
    self.zoomLevel = _zoomLevel + 1;
}

- (void)toggleCameraToPlayer:(MSPlayer)player {
    [self toggleCameraToPlayer:player animated:YES];
}

- (void)toggleCameraToPlayer:(MSPlayer)player animated:(BOOL)animated {
    SKSpriteNode *spriteNode = [self playerSpriteNodeWithPlayer:player];
    SKRange      *xRange     = [SKRange rangeWithLowerLimit:-FREE_X * GRID_SIZE upperLimit:FREE_X * GRID_SIZE];
    SKRange      *yRange     = [SKRange rangeWithLowerLimit:-FREE_Y * GRID_SIZE upperLimit:FREE_Y * GRID_SIZE];
    SKConstraint *constraint = [SKConstraint positionX:xRange Y:yRange];
    constraint.referenceNode = spriteNode;
    _cameraNode.constraints  = nil;
    [_cameraNode runAction:[SKAction moveTo:spriteNode.position duration:animated ? CAMERA_DURATION : 0.0f] completion:^{
        self->_cameraNode.constraints = @[constraint];
    }];
}

- (BOOL)movePlayer:(MSPlayer)player withDirection:(MSDirection)direction {
    [self removeGridCellSpriteNodes];
    SKSpriteNode *node      = [self playerSpriteNodeWithPlayer:player];
    CGVector      vector    = [self vectorWithDirection:direction];
    CGPoint       nextPoint = [self nextPointWithPoint:node.position vector:vector];
    BOOL          canMove   = MSCellStatusCanMove([self cellStatusWithPoint:nextPoint]);
    if (canMove && !node.hasActions) {
        [node runAction:[SKAction moveTo:nextPoint duration:MOVE_DURATION]];
    }
    return canMove;
}

- (void)synchronizePlayer:(MSPlayer)player withDirection:(MSDirection)direction {
    [self removeGridCellSpriteNodes];
    SKSpriteNode *node      = [self playerSpriteNodeWithPlayer:player];
    CGVector      vector    = [self vectorWithDirection:direction];
    CGPoint       nextPoint = [self nextPointWithPoint:node.position vector:vector];
    [node runAction:[SKAction moveTo:nextPoint duration:MOVE_DURATION]];
}

- (BOOL)drawGridCellsWithPlayer:(MSPlayer)player andRange:(NSUInteger)range {
    BOOL hasPlayer = NO;
    SKSpriteNode *playerSpriteNode = [self playerSpriteNodeWithPlayer:player];
    NSArray      *vectors          = @[[NSValue valueWithCGVector:CGVectorMake(0.f, 1.f)],
                                       [NSValue valueWithCGVector:CGVectorMake(1.f, 0.f)],
                                       [NSValue valueWithCGVector:CGVectorMake(0.f, -1.f)],
                                       [NSValue valueWithCGVector:CGVectorMake(-1.f, 0.f)]];
    [self removeGridCellSpriteNodes];
    for (NSValue *value in vectors) {
        CGVector vector = [value CGVectorValue];
        CGPoint  point  = [self nextPointWithPoint:playerSpriteNode.position vector:vector];
        BOOL noMoveZone = NO;
        for (NSUInteger i = 0; i <= range - 1; i++) {
            if (noMoveZone) {
                break;
            }
            NSString *spriteName;
            switch ([self cellStatusWithPoint:point]) {
                case MSCellStatusEmpty: {
                    spriteName = GRID_CELL_EMPTY_SPRITE_NAME;
                }
                    break;
                case MSCellStatusNoMoveZone: {
                    noMoveZone = YES;
                }
                    break;
                case MSCellStatusHasPlayer: {
                    hasPlayer  = YES;
                    noMoveZone = YES;
                    spriteName = GRID_CELL_PLAYER_SPRITE_NAME;
                }
                    break;
            }
            if (noMoveZone && !hasPlayer) {
                break;
            }
            SKSpriteNode *gridCellSpriteNode = [[SKSpriteNode alloc] initWithImageNamed:spriteName];
            gridCellSpriteNode.position      = point;
            [self addGridCellSpriteNode:gridCellSpriteNode];
            point = [self nextPointWithPoint:point vector:vector];
        }
    }
    return hasPlayer;
}

- (void)attackPlayer:(MSPlayer)attackedPlayer withAttackType:(MSAttackType)attackType andDamage:(NSUInteger)damage asCritical:(BOOL)critical {
    [self removeGridCellSpriteNodes];
    SKSpriteNode *attackedPlayerSpriteNode = [self playerSpriteNodeWithPlayer:attackedPlayer];
    SKSpriteNode *playerSpriteNode         = [self playerSpriteNodeWithPlayer:MSPlayerOtherPlayer(attackedPlayer)];
#warning
}

- (void)deathWithPlayer:(MSPlayer)player {
    [self removeGridCellSpriteNodes];
#warning
}

#pragma mark - Private methods

- (void)setupNoMoveZoneWithTileMapNode:(SKTileMapNode *)tileMapNode {
    CGSize size = tileMapNode.tileSize;
    for (NSUInteger i = 0; i <= tileMapNode.numberOfColumns - 1; i++) {
        for (NSUInteger j = 0; j <= tileMapNode.numberOfRows - 1; j++) {
            SKTileDefinition *tileDefinition = [tileMapNode tileDefinitionAtColumn:i row:j];
            BOOL border;
            @try {
                border = [tileDefinition.userData[NO_MOVE_ZONE_USER_DATA_KEY] boolValue];
            } @catch (NSException *exception) {
                border = NO;
            }
            if (border) {
                CGFloat x = (CGFloat)i * size.width;
                CGFloat y = (CGFloat)j * size.height;
                SKShapeNode *shapeNode = [SKShapeNode shapeNodeWithRect:CGRectMake(x, y, size.width, size.height)];
                shapeNode.userData     = [[NSMutableDictionary alloc] initWithDictionary:@{NO_MOVE_ZONE_USER_DATA_KEY : @(YES)}];
                shapeNode.fillColor    = [UIColor clearColor];
                shapeNode.strokeColor  = [UIColor clearColor];
                [self addChild:shapeNode];
            }
        }
    }
}

- (void)setZoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated {
    if (zoomLevel >= MIN_ZOOM_LEVEL && zoomLevel <= MAX_ZOOM_LEVEL) {
        _zoomLevel = zoomLevel;
        [_cameraNode runAction:[SKAction scaleTo:(CGFloat)_zoomLevel duration:animated ? ZOOM_DURATION : 0.0f]];
    }
}

- (void)addGridCellSpriteNode:(SKSpriteNode *)spriteNode {
    [_gridCellSpriteNodes addObject:spriteNode];
    [self addChild:spriteNode];
}

- (void)removeGridCellSpriteNodes {
    for (SKSpriteNode *node in _gridCellSpriteNodes) {
        [node removeFromParent];
    }
    [_gridCellSpriteNodes removeAllObjects];
}

- (MSCellStatus)cellStatusWithPoint:(CGPoint)point {
    for (SKNode *node in [self nodesAtPoint:point]) {
        if ([node.userData[NO_MOVE_ZONE_USER_DATA_KEY] boolValue]) {
            return MSCellStatusNoMoveZone;
        }
        if ([node.userData[PLAYER_USER_DATA_KEY] boolValue]) {
            return MSCellStatusHasPlayer;
        }
    }
    return MSCellStatusEmpty;
}

- (CGVector)vectorWithDirection:(MSDirection)direction {
    switch (direction) {
        case MSDirectionUp:
            return CGVectorMake(0.f, 1.f);
        case MSDirectionRight:
            return CGVectorMake(1.f, 0.f);
        case MSDirectionDown:
            return CGVectorMake(0.f, -1.f);
        case MSDirectionLeft:
            return CGVectorMake(-1.f, 0.f);
    }
}

- (CGPoint)nextPointWithPoint:(CGPoint)point vector:(CGVector)vector {
    return CGPointMake(point.x + GRID_SIZE * vector.dx,
                       point.y + GRID_SIZE * vector.dy);
}

- (SKSpriteNode *)playerSpriteNodeWithPlayer:(MSPlayer)player {
    switch (player) {
        case MSPlayerA:
            return _playerA;
        case MSPlayerB:
            return _playerB;
    }
}

#pragma mark - Public properties

- (void)setZoomLevel:(NSUInteger)zoomLevel {
    [self setZoomLevel:zoomLevel animated:YES];
}

@end
