//
//  UIView+Localizable.m
//  UIView+Localizable
//
//  Created by Vladimir Psyukalov on 02.07.2018.
//  Copyright © 2018 YOUROCK INC. All rights reserved.
//


#import "UIView+Localizable.h"


@implementation UIView (Localizable)

- (void)localizable {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.text = NSLocalizedString(label.text, nil);
        } else if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitle:NSLocalizedString(button.titleLabel.text, nil) forState:UIControlStateNormal];
        } else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            textField.placeholder = NSLocalizedString(textField.placeholder, nil);
        } else {
            [subview localizable];
        }
    }
}

@end
