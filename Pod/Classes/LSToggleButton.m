/*!
 * This file is part of LSTextEditor.
 *
 * Copyright © 2015 LShift Services GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Authors:
 * - Peter Lieder <peter@lshift.de>
 *
 */

#import "LSToggleButton.h"

@implementation LSToggleButton

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 30, 0) andTitle:nil];
}

- (instancetype)initWithFrame:(CGRect)frame andTitle:(NSString *)title
{
    if (self = [super initWithFrame:frame])
    {
        self.isActive = NO;
        [self addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self setTitle:title forState:UIControlStateNormal];
        CALayer *buttonLayer = [self layer];
        [buttonLayer setMasksToBounds:YES];
        [buttonLayer setCornerRadius:4.0f];
        [buttonLayer setBorderWidth:1.0f];

        [self updateButtonStyle];
    }
    
    return self;
}

- (void)updateButtonStyle
{
    CALayer *buttonLayer = [self layer];

    UIColor *titleColor = self.isActive ?
                            [UIColor colorWithRed:222.0f / 255.0f green:222.0f / 255.0f blue:222.0f / 255.0f alpha:1.0f] :
                            [UIColor darkGrayColor];

    UIColor *backgroundColor = self.isActive ?
                                [UIColor lightGrayColor] :
                                [UIColor colorWithRed:225.0f / 255.0f green:225.0f / 255.0f blue:225.0f / 255.0f alpha:1.0f];

    CGColorRef borderColor = self.isActive ?
                                [[UIColor colorWithRed:150.0f / 255.0f green:150.0f / 255.0f blue:150.0f / 255.0f alpha:1.0f] CGColor] :
                                [[UIColor colorWithRed:205.0f / 255.0f green:205.0f / 255.0f blue:205.0f / 255.0f alpha:1.0f] CGColor];

    [UIView animateWithDuration:0.2 animations:^{
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        [self setBackgroundColor:backgroundColor];
        [buttonLayer setBorderColor:borderColor];
    }];
}

- (void)buttonTapped:(id)sender
{
    self.isActive = !self.isActive;
    [self updateButtonStyle];
}

- (void)setIsActive:(BOOL)isActive
{
    _isActive = isActive;
    [self updateButtonStyle];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
