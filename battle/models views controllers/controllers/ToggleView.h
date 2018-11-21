//
//  ToggleView.h
//  battle
//
//  Created by Vladimir Psyukalov on 20.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "GamePadViewController.h"


@class ToggleView;


@protocol ToggleViewDelegate <NSObject>

@optional

- (void)toggleView:(ToggleView *)view didSelectItemLabelWithIndex:(NSUInteger)index;

@end


@interface ToggleView : UIView <GamePadViewControllerDelegate>

@property (weak, nonatomic) id<ToggleViewDelegate> delegate;

@property (assign, nonatomic) NSUInteger currentItemIndex;

- (void)addItemLabel:(UILabel *)itemLabel;

- (void)selectWithCurrentItemIndex;

@end
