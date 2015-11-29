//
//  LSTextStorage.h
//  LSTextEditor
//
//  Created by Peter Lieder on 14/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSRichTextView;

typedef NS_ENUM(NSInteger, LSFontStyleType) {
    LSFontStyleTypeBold,
    LSFontStyleTypeItalic,
    LSFontStyleTypeUnderlined,
    LSFontStyleTypeStrokeThrough
};

@interface LSTextStorage : NSTextStorage

- (instancetype)initWithTextView:(LSRichTextView *)textView;

// returns the plain text without markup
- (NSString *)string;
- (NSString *)createOutputString;
- (NSString *)createOutputString2;
- (void)applyTraitChangeToRange:(NSRange)range andTraitValue:(uint32_t)traitValue;
- (void)applyUnderlineChangeToRange:(NSRange)range andStyleAttributeName:(NSString *)styleAttributeName;

- (void)processLinkDetection;
- (void)setAttributedText:(NSAttributedString *)attributedText;

@end
