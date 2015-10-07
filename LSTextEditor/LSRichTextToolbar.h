//
//  LSRichTextToolbar.h
//  LSTextEditor
//
//  Created by Peter Lieder on 16/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRichTextConfiguration.h"


@protocol LSRichTextToolbarDelegate <NSObject>

- (void)richTextToolbarDidSelectBold:(BOOL)isActive;
- (void)richTextToolbarDidSelectItalic:(BOOL)isActive;
- (void)richTextToolbarDidSelectUnderlined:(BOOL)isActive;
- (void)richTextToolbarDidSelectStrikeThrough:(BOOL)isActive;

@end

@interface LSRichTextToolbar : UIView

@property (nonatomic, weak) id <LSRichTextToolbarDelegate> delegate;
@property (nonatomic, weak) LSRichTextConfiguration *richTextConfiguration;

- (instancetype)initWithFrame:(CGRect)frame withDelegate:(id <LSRichTextToolbarDelegate>)delegate andConfiguration:(LSRichTextConfiguration *)configuration;
- (void)updateStateWithAttributes:(NSDictionary *)attributes;

@end
