//
//  UITextField+OKCarriageColor.h
//  OKTestWork
//
//  Created by Vitaliy Berg on 2/21/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (OKCarriageColor)

// Change carriage color to specified color.
// Use in delegate method - (void)textFieldDidBeginEditing:
// Tested in iOS 5.1.1 and iOS 6.0 (simulator)
- (void)changeCarriageColorWithColor:(UIColor *)color;

@end
