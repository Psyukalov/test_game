//
//  ToggleView.m
//  battle
//
//  Created by Vladimir Psyukalov on 20.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "ToggleView.h"


@interface ToggleView ()

@property (strong, nonatomic) UIImageView *arrowImageView;

@property (strong, nonatomic) NSMutableArray<UILabel *> *itemLabels;

@end


@implementation ToggleView

#pragma mark - Initialization methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Private methods

- (void)setup {
    _itemLabels = [NSMutableArray new];
}

#pragma mark - Public methods

- (void)addItemLabel:(UILabel *)itemLabel {
    if (!itemLabel) {
        return;
    }
    [_itemLabels addObject:itemLabel];
}

- (void)selectWithCurrentItemIndex {
    if ([_delegate respondsToSelector:@selector(toggleView:didSelectItemLabelWithIndex:)]) {
        [_delegate toggleView:self didSelectItemLabelWithIndex:_currentItemIndex];
    }
}

#pragma mark - Public properties

- (void)setCurrentItemIndex:(NSUInteger)currentItemIndex {
    if (currentItemIndex > _itemLabels.count - 1) {
        return;
    }
    _currentItemIndex = currentItemIndex;
    for (UILabel *itemLabel in _itemLabels) {
        itemLabel.highlighted = NO;
    }
    _itemLabels[_currentItemIndex].highlighted = YES;
}

#pragma mark - GamePadViewControllerDelegate

- (void)gamePadViewController:(GamePadViewController *)viewController didPressDirectionButton:(GPVCDirectionButton)directionButton {
    NSInteger index = _currentItemIndex;
    switch (directionButton) {
        case GPVCDirectionButtonUp: {
            index--;
            if (index < 0) {
                index = _itemLabels.count - 1;
            }
            self.currentItemIndex = index;
        }
            break;
        case GPVCDirectionButtonDown: {
            index++;
            if (index > _itemLabels.count - 1) {
                index = 0;
            }
            self.currentItemIndex = index;
        }
            break;
        default:
            break;
    }
}

- (void)gamePadViewController:(GamePadViewController *)viewController didPressActionButton:(GPVCActionButton)actionButton {
    [self selectWithCurrentItemIndex];
}

- (void)didPressMenuWithGamePadViewController:(GamePadViewController *)viewController {
    // Empty...
}

- (void)didPressInfoWithGamePadViewController:(GamePadViewController *)viewController {
    // Empty...
}

@end
