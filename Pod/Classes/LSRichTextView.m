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

#import "LSRichTextView.h"
#import "LSTextStorage.h"
#import "LSRichTextToolbar.h"
#import "LSRichTextConfiguration.h"

#define LSTEXTVIEW_TOOLBAR_HEIGHT 40

@interface LSRichTextView () <LSRichTextToolbarDelegate, NSLayoutManagerDelegate, NSTextStorageDelegate>

@property (nonatomic, strong) LSRichTextToolbar *toolBar;

@end

@implementation LSRichTextView
{
    LSTextStorage *_textStorage;
    BOOL _scrollEnabledSave;
}

#pragma mark - view lifecycle

- (instancetype)init
{
    // frame will be set to zero, text field size is defined by constraints in IB
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        _richTextConfiguration = [[LSRichTextConfiguration alloc] initWithTextFeatures:LSRichTextFeaturesAll];
        [self commonSetup:self.textContainer];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andConfiguration:(LSRichTextConfiguration *)configuration
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _richTextConfiguration = configuration;
        [self commonSetup:self.textContainer];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andConfiguration:[[LSRichTextConfiguration alloc] initWithTextFeatures:LSRichTextFeaturesAll]];
}

- (void)commonSetup:(NSTextContainer *)textContainer
{
    _scrollEnabledSave = self.scrollEnabled;
    self.scrollEnabled = NO;

    NSString *existingText = [self.text copy];
    textContainer.layoutManager.delegate = self;

    [self.textStorage removeLayoutManager:self.layoutManager];
    self.textStorage.delegate = nil;

    // Create the text storage that backs the editor
    _textStorage = [self createTextStorage];
    _textStorage.delegate = self;

    // addds the text storage to the existing layout manager
    [_textStorage removeLayoutManager:_textStorage.layoutManagers.firstObject];
    [_textStorage addLayoutManager:textContainer.layoutManager];

    textContainer.widthTracksTextView = NO;
    [self.richTextConfiguration setTextCheckingType:self.dataDetectorTypes];
    self.dataDetectorTypes = UIDataDetectorTypeNone;

    // initializes the toolbar
    self.toolBar = [[LSRichTextToolbar alloc] initWithFrame:
                    CGRectMake(0, 0, [self currentScreenBoundsDependOnOrientation].size.width, LSTEXTVIEW_TOOLBAR_HEIGHT)
                                               withDelegate:self
                                           andConfiguration:self.richTextConfiguration];

    self.delaysContentTouches = NO;

    [self setNeedsDisplay];
    self.scrollEnabled = _scrollEnabledSave;
    self.text = existingText;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    [self.richTextConfiguration setInitialAttributesFromTextView:self];
    self.richTextConfiguration.defaultTextColor = self.textColor;
}

- (LSTextStorage *)createTextStorage
{
    return [[LSTextStorage alloc] initWithTextView:self];
}

#pragma mark - override methods

- (NSTextStorage *)textStorage
{
    return _textStorage ?: super.textStorage;
}

- (LSTextStorage *)customTextStorage
{
    return _textStorage;
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange
{
    [super setSelectedTextRange:selectedTextRange];

    if ([self isFirstResponder]) {
        [self updateToolbarStatus];
    }
}

- (BOOL)canBecomeFirstResponder
{
    LSRichTextFeatures features = self.richTextConfiguration.configurationFeatures;

    if (features & LSRichTextFeaturesNone || features & LSRichTextFeaturesReadonly) {
        self.inputAccessoryView = nil;
        return NO;
    } else {
        self.inputAccessoryView = self.toolBar;
    }

    return [super canBecomeFirstResponder];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.isEditable && ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
        [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]))
    {
        // tap on detected links are blocked here and handled with
        // custom recognizer, avoids crash in NSConcreteTextStorage
        [self handleTextTapped:gestureRecognizer];
        return NO;
    }

    return YES;
}

- (void)handleTextTapped:(UIGestureRecognizer *)gestureRecognizer
{
    UITextView *textView = (UITextView *)gestureRecognizer.view;
    if (textView != self) {
        return;
    }

    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [gestureRecognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;

    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:textView.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];

    if (characterIndex < textView.textStorage.length) {

        NSRange range;
        NSDictionary *attributes = [self.customTextStorage attributesAtIndex:characterIndex effectiveRange:&range];

        NSURL *link = [attributes objectForKey:NSLinkAttributeName];
        if (!link || range.location == NSNotFound || NSMaxRange(range) > textView.textStorage.length) {
            return;
        }

        if ([self.delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)] &&
            [self.delegate textView:self shouldInteractWithURL:link inRange:range]) {
            [[UIApplication sharedApplication] openURL:link];
        }
    }
}

#pragma mark - text touch & highlight handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setHighlighted:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setHighlighted:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setHighlighted:NO];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (!self.richTextConfiguration.highlightColor) {
        return;
    }

    if (highlighted) {
        [self setTextColor:self.richTextConfiguration.highlightColor];
    } else {
        [self setTextColor:self.richTextConfiguration.defaultTextColor];
    }

    [self setNeedsDisplay];
}

#pragma mark - accessors

-(NSString *)text
{
    return self.customTextStorage.string;
}

- (void)setText:(NSString *)text
{
    // Note: If the current selected range is outsite of the text
    // string we need to adjust the selected position for fitting into valid
    // range. A selected range with length > 0 should be removed completely.

    if (NSMaxRange(self.selectedRange) >= text.length) {
        NSUInteger newLocation = (text.length > 0) ? text.length - 1 : 0;
        [self setSelectedRange:NSMakeRange(newLocation, 0)];
    }

    [super setText:text];

    if (self.richTextConfiguration.textCheckingTypes != 0) {
        [self.customTextStorage processDataDetection];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    // use a custom handling of setting text instead of
    // the one from NSTextStorage
    [self.customTextStorage setAttributedText:[attributedText mutableCopy]];
}

- (NSString *)plainText
{
    return [self.customTextStorage string];
}

- (NSString *)encodedText
{
    return [self.customTextStorage createOutputString];
}

- (void)resetTextFormatting
{
    [self.customTextStorage setAttributes:self.richTextConfiguration.initialTextAttributes range:NSMakeRange(0, self.customTextStorage.string.length)];
    [self updateToolbarStatus];
}

- (void)setHighlightColor:(UIColor *)color
{
    self.richTextConfiguration.highlightColor = color;
}

#pragma LSRichTextToolbarDelegate methods

- (void)richTextToolbarDidSelectBold:(BOOL)isActive
{
    [self.customTextStorage applyTraitChangeToRange:self.selectedRange andTraitValue:UIFontDescriptorTraitBold];
}

- (void)richTextToolbarDidSelectItalic:(BOOL)isActive
{
    [self.customTextStorage applyTraitChangeToRange:self.selectedRange andTraitValue:UIFontDescriptorTraitItalic];
}

- (void)richTextToolbarDidSelectUnderlined:(BOOL)isActive
{
    [self.customTextStorage applyUnderlineChangeToRange:self.selectedRange andStyleAttributeName:NSUnderlineStyleAttributeName];
}

- (void)richTextToolbarDidSelectStrikeThrough:(BOOL)isActive
{
    [self.customTextStorage applyUnderlineChangeToRange:self.selectedRange andStyleAttributeName:NSStrikethroughStyleAttributeName];
}

#pragma mark - NSTextStorageDelegate methods

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    [self updateToolbarStatus];
}

#pragma mark - NSLayoutManagerDelegate methods

#pragma helpers

- (void)updateToolbarStatus
{
    if (![self hasText])
    {
        [self.toolBar updateStateWithAttributes:self.typingAttributes];
    }
    else
    {
        NSUInteger location = self.selectedRange.location;
        [self.toolBar updateStateWithAttributes:[self attributesDictAtIndex:location]];
    }
}

- (NSDictionary *)attributesDictAtIndex:(NSInteger)index
{
    // If index at end of string, get attributes starting from previous character
    if (index == self.customTextStorage.string.length && [self hasText]) {
        --index;
    }
    
    if (index >= self.customTextStorage.length) {
        index = self.customTextStorage.length - 1;
    }
    
    // If no text exists get font from typing attributes
    return  ([self hasText])
    ? [self.customTextStorage attributesAtIndex:index effectiveRange:nil]
    : self.typingAttributes;
}

- (CGRect)currentScreenBoundsDependOnOrientation
{
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(width, height);
    }
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(height, width);
    }
    
    return screenBounds;
}

@end
