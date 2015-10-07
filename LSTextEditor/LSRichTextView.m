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

@interface LSRichTextView () <LSRichTextToolbarDelegate, NSLayoutManagerDelegate>

@property (nonatomic, strong) LSRichTextToolbar *toolBar;

@end


@implementation LSRichTextView
{
    LSTextStorage *_textStorage;
}

#pragma lifecycle

- (instancetype)init
{
    // frame will be set to zero, text field size is defined by constraints in IB
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.richTextConfiguration = [[LSRichTextConfiguration alloc] initWithConfiguration:LSRichTextFeaturesAll];
        [self lazySetup:self.textContainer];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andConfiguration:(LSRichTextConfiguration *)configuration
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.richTextConfiguration = configuration;
        [self lazySetup:self.textContainer];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andConfiguration:[[LSRichTextConfiguration alloc] initWithConfiguration:LSRichTextFeaturesAll]];
}

- (void)lazySetup:(NSTextContainer *)textContainer
{
    [self.textStorage removeLayoutManager:self.layoutManager];
    
    // Create the text storage that backs the editor
    _textStorage = [self createTextStorage];
    _textStorage.delegate = self;
    
    // addds the text storage to the existing layout manager
    [_textStorage addLayoutManager:textContainer.layoutManager];
    textContainer.layoutManager.delegate = self;
    [textContainer.layoutManager setTextStorage:_textStorage];
    
    textContainer.widthTracksTextView = YES;
    
    // initializes the toolbar
    self.toolBar = [[LSRichTextToolbar alloc] initWithFrame:
                    CGRectMake(0, 0, [self currentScreenBoundsDependOnOrientation].size.width, LSTEXTVIEW_TOOLBAR_HEIGHT)
                                               withDelegate:self
                                           andConfiguration:self.richTextConfiguration];
}

- (LSTextStorage *)createTextStorage
{
    return [[LSTextStorage alloc] init];
}

#pragma mark - override methods

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange
{
    [super setSelectedTextRange:selectedTextRange];
    
    [self updateToolbarStatus];
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

#pragma mark - event handlers

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    if (editedMask == NSTextStorageEditedAttributes) {
        
    } else if (editedMask == NSTextStorageEditedCharacters) {
        
    } else {
    
    }
}

#pragma accessors

-(NSString *)text
{
    return _textStorage.string;
}

- (void)setText:(NSString *)text
{
    // Note: we can't set nil values to _textStorage so we replace them with
    // an empty string. If the current selected range is outsite of the text
    // string we need to adjust the selected position for fitting into valid
    // range. A selected range with length > 0 should be removed completely.
    if (!text) {
        text = @"";
    }

    [super setText:text];

    /*
    if (NSMaxRange(self.selectedRange) >= text.length) {
        NSUInteger newLocation = (text.length > 0) ? text.length - 1 : 0;
        [self setSelectedRange:NSMakeRange(newLocation, 0)];
    }


    [_textStorage replaceCharactersInRange:NSMakeRange(0, _textStorage.string.length) withString:text];

    self.linkTextAttributes = @{NSForegroundColorAttributeName: self.tintColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle], NSFontAttributeName:self.font};
    [self layoutIfNeeded];
     */
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [_textStorage setAttributedString:attributedText];
}

- (NSString *)plainText
{
    return [_textStorage string];
}

- (NSString *)encodedText
{
    return [_textStorage createOutputString];
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
