//
//  UITextField+OKCarriageColor.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 2/21/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "UITextField+OKCarriageColor.h"

@implementation UITextField (OKCarriageColor)

- (void)changeCarriageColorWithColor:(UIColor *)color
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UITextSelectionView")]) {
            if ([subview.subviews count] > 0) {
                UIView *carriage = subview.subviews[0];
                carriage.backgroundColor = color;
            }
        }
    }
}

@end
