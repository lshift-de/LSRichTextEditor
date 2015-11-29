//
//  LSTextEditorView.h
//  LSTextEditor
//
//  Created by Peter Lieder on 14/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRichTextConfiguration.h"

@interface LSRichTextView : UITextView <NSTextStorageDelegate>

@property (nonatomic, strong, readonly) LSRichTextConfiguration *richTextConfiguration;

- (NSString *)plainText;
- (NSString *)encodedText;

- (instancetype)initWithFrame:(CGRect)frame andConfiguration:(LSRichTextConfiguration *)configuration;
- (void)setText:(NSString *)text;
- (void)resetTextFormatting;
- (void)setHighlightColor:(UIColor *)color;

@end
