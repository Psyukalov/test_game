//
//  GamePadViewController.m
//  battle
//
//  Created by Vladimir Psyukalov on 19.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "GamePadViewController.h"

#define MIN_ZONE_RATIO (0.3f)
#define MAX_ZONE_RATIO (0.7f)

#define DIRECTION_DEFAULT_IMAGE_NAME (@"directions_default_button")
#define DIRECTION_UP_IMAGE_NAME      (@"directions_up_button")
#define DIRECTION_RIGHT_IMAGE_NAME   (@"directions_right_button")
#define DIRECTION_DOWN_IMAGE_NAME    (@"directions_down_button")
#define DIRECTION_LEFT_IMAGE_NAME    (@"directions_left_button")


typedef NS_ENUM(NSUInteger, GPVCDirection) {
    GPVCDirectionNone = 0,
    GPVCDirectionUp,
    GPVCDirectionRight,
    GPVCDirectionDown,
    GPVCDirectionLeft
};


@interface GamePadViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *directionsImageView;

@property (weak, nonatomic) IBOutlet UIButton *aButton;
@property (weak, nonatomic) IBOutlet UIButton *bButton;
@property (weak, nonatomic) IBOutlet UIButton *cButton;
@property (weak, nonatomic) IBOutlet UIButton *dButton;

@property (strong, nonatomic) NSArray<UIImage *> *directionsImages;

@property (assign, nonatomic) GPVCDirection direction;

@end


@implementation GamePadViewController

#pragma mark - Public static methods

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

#pragma mark - Overriding methods

- (void)viewDidLoad {
    [super viewDidLoad];
    @try {
        _directionsImages = @[[UIImage imageNamed:DIRECTION_DEFAULT_IMAGE_NAME],
                              [UIImage imageNamed:DIRECTION_UP_IMAGE_NAME],
                              [UIImage imageNamed:DIRECTION_RIGHT_IMAGE_NAME],
                              [UIImage imageNamed:DIRECTION_DOWN_IMAGE_NAME],
                              [UIImage imageNamed:DIRECTION_LEFT_IMAGE_NAME]];
        
    } @catch (NSException *exception) {
        // Empty...
    }
    self.direction = GPVCDirectionNone;
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlerGestureRecognizer:)];
    gestureRecognizer.minimumPressDuration = 0.f;
    [_directionsImageView addGestureRecognizer:gestureRecognizer];
}

#pragma mark - Private methods

- (void)didPressActionButton:(GPVCActionButton)actionButton {
    if ([_delegate respondsToSelector:@selector(gamePadViewController:didPressActionButton:)]) {
        [_delegate gamePadViewController:self didPressActionButton:actionButton];
    }
}

- (void)didPressDirectionButton:(GPVCDirectionButton)directionButton {
    if ([_delegate respondsToSelector:@selector(gamePadViewController:didPressDirectionButton:)]) {
        [_delegate gamePadViewController:self didPressDirectionButton:directionButton];
    }
}

#pragma mark - Public methods

- (void)updateViewLayout {
    self.view.frame = _parentView.bounds;
}

#pragma mark - Private properties

- (void)setDirection:(GPVCDirection)direction {
    _direction = direction;
    @try {
        _directionsImageView.image = _directionsImages[_direction];
    } @catch (NSException *exception) {
        // Empty...
    }
}

#pragma mark - Public properties

- (void)setOn:(BOOL)on {
    _on = on;
    _aButton.enabled = _on;
    _bButton.enabled = _on;
    _cButton.enabled = _on;
    _dButton.enabled = _on;
}

- (void)setParentView:(UIView *)parentView {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    if (!parentView) {
        return;
    }
    _parentView = parentView;
    [_parentView addSubview:self.view];
}

#pragma mark - Handlers

- (void)handlerGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (!_on) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat w = gestureRecognizer.view.frame.size.width;
    CGFloat h = gestureRecognizer.view.frame.size.height;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            if (p.x >= MIN_ZONE_RATIO * w && p.x <= MAX_ZONE_RATIO * w && p.y <= MIN_ZONE_RATIO * h) {
                self.direction = GPVCDirectionUp;
                [self didPressDirectionButton:GPVCDirectionButtonUp];
            } else if (p.x >= MAX_ZONE_RATIO * w && p.y >= MIN_ZONE_RATIO * h && p.y <= MAX_ZONE_RATIO * h) {
                self.direction = GPVCDirectionRight;
                [self didPressDirectionButton:GPVCDirectionButtonRight];
            } else if (p.x >= MIN_ZONE_RATIO * w && p.x <= MAX_ZONE_RATIO * w && p.y >= MAX_ZONE_RATIO * h) {
                self.direction = GPVCDirectionDown;
                [self didPressDirectionButton:GPVCDirectionButtonDown];
            } else if (p.x <= MIN_ZONE_RATIO * w && p.y >= MIN_ZONE_RATIO * h && p.y <= MAX_ZONE_RATIO * h) {
                self.direction = GPVCDirectionLeft;
                [self didPressDirectionButton:GPVCDirectionButtonLeft];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (p.x < 0.0f || p.y < 0.0f || p.x > w || p.y > h) {
                self.direction = GPVCDirectionNone;
            }
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.direction = GPVCDirectionNone;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Actions

- (IBAction)aButton_TUI:(UIButton *)sender {
    [self didPressActionButton:GPVCActionButtonA];
}

- (IBAction)bButton_TUI:(UIButton *)sender {
    [self didPressActionButton:GPVCActionButtonB];
}

- (IBAction)cButton_TUI:(UIButton *)sender {
    [self didPressActionButton:GPVCActionButtonC];
}

- (IBAction)dButton_TUI:(UIButton *)sender {
    [self didPressActionButton:GPVCActionButtonD];
}

- (IBAction)menuButton_TUI:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didPressMenuWithGamePadViewController:)]) {
        [_delegate didPressMenuWithGamePadViewController:self];
    }
}

- (IBAction)infoButton_TUI:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didPressInfoWithGamePadViewController:)]) {
        [_delegate didPressInfoWithGamePadViewController:self];
    }
}

@end
