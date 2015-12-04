//
//  LSToggleButton.h
//  LSTextEditor
//
//  Created by Peter Lieder on 16/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSToggleButton : UIButton

@property (nonatomic, assign) BOOL isActive;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title;

@end
