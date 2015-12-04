//
//  LSTextView.m
//
//  Created by Peter Lieder on 14/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

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
        _richTextConfiguration = [[LSRichTextConfiguration alloc] initWithConfiguration:LSRichTextFeaturesAll];
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
    return [self initWithFrame:frame andConfiguration:[[LSRichTextConfiguration alloc] initWithConfiguration:LSRichTextFeaturesAll]];
}

- (void)commonSetup:(NSTextContainer *)textContainer
{
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

    textContainer.widthTracksTextView = YES;
    [self.richTextConfiguration setTextCheckingType:self.dataDetectorTypes];
    self.dataDetectorTypes = UIDataDetectorTypeNone;

    // initializes the toolbar
    self.toolBar = [[LSRichTextToolbar alloc] initWithFrame:
                    CGRectMake(0, 0, [self currentScreenBoundsDependOnOrientation].size.width, LSTEXTVIEW_TOOLBAR_HEIGHT)
                                               withDelegate:self
                                           andConfiguration:self.richTextConfiguration];

    self.delaysContentTouches = NO;

    [self setNeedsDisplay];

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
        NSDictionary *attributes = [_textStorage attributesAtIndex:characterIndex effectiveRange:&range];

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
    return _textStorage.string;
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

    if (self.richTextConfiguration.textCheckingTypes & ~0) {
        [_textStorage processLinkDetection];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    // use a custom handling of setting text instead of
    // the one from NSTextStorage
    [_textStorage setAttributedText:[attributedText mutableCopy]];
}

- (NSString *)plainText
{
    return [_textStorage string];
}

- (NSString *)encodedText
{
    return [_textStorage createOutputString];
}

- (void)resetTextFormatting
{
    [_textStorage setAttributes:self.richTextConfiguration.initialTextAttributes range:NSMakeRange(0, _textStorage.string.length)];
    [self updateToolbarStatus];
}

- (void)setHighlightColor:(UIColor *)color
{
    self.richTextConfiguration.highlightColor = color;
}

#pragma LSRichTextToolbarDelegate methods

- (void)richTextToolbarDidSelectBold:(BOOL)isActive
{
    [_textStorage applyTraitChangeToRange:self.selectedRange andTraitValue:UIFontDescriptorTraitBold];
}

- (void)richTextToolbarDidSelectItalic:(BOOL)isActive
{
    [_textStorage applyTraitChangeToRange:self.selectedRange andTraitValue:UIFontDescriptorTraitItalic];
}

- (void)richTextToolbarDidSelectUnderlined:(BOOL)isActive
{
    [_textStorage applyUnderlineChangeToRange:self.selectedRange andStyleAttributeName:NSUnderlineStyleAttributeName];
}

- (void)richTextToolbarDidSelectStrikeThrough:(BOOL)isActive
{
    [_textStorage applyUnderlineChangeToRange:self.selectedRange andStyleAttributeName:NSStrikethroughStyleAttributeName];
}

#pragma mark - NSTextStorageDelegate methods

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    [self updateToolbarStatus];
}

#pragma mark - NSLayoutManagerDelegate methods

/*
- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
{
    NSRange range;
    NSURL *linkURL = [layoutManager.textStorage attribute:NSLinkAttributeName atIndex:charIndex effectiveRange:&range];
    
    // Do not break lines in links unless absolutely required
    if (linkURL && charIndex > range.location && charIndex <= NSMaxRange(range))
        return NO;
    else
        return YES;
}
*/

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
    if (index == _textStorage.string.length && [self hasText]) {
        --index;
    }
    
    if (index >= _textStorage.length) {
        index = _textStorage.length - 1;
    }
    
    // If no text exists get font from typing attributes
    return  ([self hasText])
    ? [_textStorage attributesAtIndex:index effectiveRange:nil]
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
