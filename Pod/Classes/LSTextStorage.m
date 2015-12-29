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

#import "LSTextStorage.h"
#import "LSRichTextView.h"
#import "LSParser.h"

@interface LSTextStorage ()

@property (nonatomic, strong, readonly) LSRichTextView *textView;
@property (nonatomic, strong, readonly) NSArray *allowedTags;

@end

@implementation LSTextStorage {
    NSMutableAttributedString *_backingStore;
}

- (instancetype)initWithTextView:(LSRichTextView *)textView
{
    if (self = [super init]) {
        _backingStore = [NSMutableAttributedString new];
        _textView = textView;
        _allowedTags = @[@"b", @"i", @"u", @"s"];
    }
    return self;
}

#pragma mark - overrides of NSTextStorage

- (NSString *)string
{
    return [_backingStore string];
}

- (NSUInteger)length
{
    return _backingStore.length;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location
                     effectiveRange:(NSRangePointer)range
{
    return [_backingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    NSLog(@"replaceCharactersInRange:%@ withString:%@", NSStringFromRange(range), str);

    [self beginEditing];
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes
           range:range
  changeInLength:str.length - range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    NSLog(@"setAttributes:%@ range:%@", attrs, NSStringFromRange(range));
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    
    UIFont *font = [attrs objectForKey:NSFontAttributeName];
    
    if (!font) {
        attributes = [NSMutableDictionary dictionaryWithDictionary:
                      self.textView.richTextConfiguration.initialTextAttributes];
    }

    [self beginEditing];
    [_backingStore setAttributes:attributes range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

#pragma mark - input formatting

- (void)processEditing
{
    // TODO: needs to be adapted for real time checking of tags
    /*
    LSRichTextFeatures features = self.textView.richTextConfiguration.configurationFeatures;
    if (features & ~LSRichTextFeaturesNone) {
        [self performReplacementsForRange:[self editedRange]];
    }
     */
    [super processEditing];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    NSRange extendedRange = [self calculateMultilineRange:NSMakeRange(0, attributedText.length) andTextString:attributedText.string];
    LSRichTextFeatures features = self.textView.richTextConfiguration.configurationFeatures;

    if (features & ~LSRichTextFeaturesNone) {
        [self applyStylesToRange:extendedRange withAttributedText:attributedText];
    } else {
        [self setAttributedString:attributedText];
    }
}

- (void)performReplacementsForRange:(NSRange)changedRange
{
    // TODO: needs to be adapted for real time checking of tags
    /*
    NSRange extendedRange = [self calculateMultilineRange:changedRange];
    [self applyStylesToRange:extendedRange];
     */
}

- (void)applyStylesToRange:(NSRange)searchRange withAttributedText:(NSAttributedString *)attributedText
{
    LSParser *parser = [LSParser new];
    LSNode *rootNode = [parser parseString:attributedText.string error:nil];

    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] init];

    [self processParsedString:rootNode resultString:&resultString fromSourceText:attributedText];

    [self setAttributedString:resultString];
}

- (void)processParsedString:(LSNode *)currentNode resultString:(NSMutableAttributedString **)outString
             fromSourceText:(NSAttributedString *)attributedText
{
    __block NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] init];
    
    if (currentNode.tagName) {
        [currentNode.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self processParsedString:(LSNode *)obj resultString:&resultString fromSourceText:attributedText];
        }];
    } else {
        NSRange originRange = [attributedText.string rangeOfString:currentNode.content];
        NSAttributedString *preservedAttributedString = [attributedText attributedSubstringFromRange:originRange];
        
        [resultString appendAttributedString:preservedAttributedString];

        if (self.textView.richTextConfiguration.configurationFeatures & ~LSRichTextFeaturesPlainText) {
            [currentNode.tagNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([self.allowedTags containsObject:obj]) {
                    NSRange currentRange = NSMakeRange(0, resultString.length);
                    NSDictionary *newAttributes = [self createActualAttributeStyle:currentRange
                                                                    forTagName:obj
                                                                      withText:resultString];
                    [resultString addAttributes:newAttributes range:currentRange];
                }
            }];
        }
    }
    
    [*outString appendAttributedString:resultString];
}

#pragma mark - data detection

- (void)processDataDetection
{
    static NSDataDetector *linkDetector;
    linkDetector = linkDetector ?: [[NSDataDetector alloc] initWithTypes:self.textView.richTextConfiguration.textCheckingTypes
                                                                   error:NULL];

    NSRange extendedRange = [self calculateMultilineRange:NSMakeRange(0, self.length) andTextString:self.string];

    // remove existing data link attributes
    [self removeAttribute:NSLinkAttributeName range:extendedRange];

    __weak LSTextStorage *weakSelf = self;
    
    // Find all data types in range
    [linkDetector enumerateMatchesInString:self.string options:0 range:extendedRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if ([result resultType] == NSTextCheckingTypeLink) {
            [self removeAttribute:NSUnderlineStyleAttributeName range:result.range];
            [_backingStore addAttributes:@{NSLinkAttributeName : result.URL,
                                           NSForegroundColorAttributeName : weakSelf.textView.tintColor,
                                           NSFontAttributeName : weakSelf.textView.font}
                                   range:result.range];
        }
    }];
}

#pragma mark - interactive formatters

- (void)applyTraitChangeToRange:(NSRange)range andTraitValue:(uint32_t)traitValue
{
    UIFont *currentFont = [self fontAtIndex:range.location];
    UIFontDescriptor *fontDescriptor = [currentFont fontDescriptor];

    if (!fontDescriptor) {
        fontDescriptor = [self.textView.richTextConfiguration.initialTextAttributes[NSFontAttributeName] fontDescriptor];
    }

    UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;
    BOOL isEnabled = (fontDescriptorSymbolicTraits & traitValue) != 0;

    UIFontDescriptor *changedFontDescriptor;

    if (!isEnabled) {
        UIFontDescriptorSymbolicTraits existingTraitsWithNewTrait = [fontDescriptor symbolicTraits] | traitValue;
        changedFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithNewTrait];
    } else {
        UIFontDescriptorSymbolicTraits existingTraitsWithoutTrait = [fontDescriptor symbolicTraits] & ~traitValue;
        changedFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithoutTrait];
    }

    if (!changedFontDescriptor) return;

    NSDictionary *changedAttributes = @{NSFontAttributeName:[UIFont fontWithDescriptor:changedFontDescriptor size:0.0]};
    
    if (range.length > 0) {
        [self addAttributes:changedAttributes range:range];
    } else {
        NSMutableDictionary *dictionary = [[self.textView typingAttributes] mutableCopy];
        [dictionary setObject:[changedAttributes valueForKey:NSFontAttributeName] forKey:NSFontAttributeName];
        [self.textView setTypingAttributes:dictionary];
    }
}

- (void)applyUnderlineChangeToRange:(NSRange)range andStyleAttributeName:(NSString *)styleAttributeName
{
    NSDictionary *currentAttributesDict = (range.length > 0) ? [_backingStore attributesAtIndex:range.location effectiveRange:nil]
                                                             :  self.textView.typingAttributes;

    NSDictionary *newAttributes;

    if ([currentAttributesDict objectForKey:styleAttributeName] == nil ||
        [[currentAttributesDict objectForKey:styleAttributeName] intValue] == 0) {
        newAttributes = @{styleAttributeName: [NSNumber numberWithInt:1]};
    }
    else{
        newAttributes = @{styleAttributeName: [NSNumber numberWithInt:0]};
    }

    if (range.length > 0) {
        [self addAttributes:newAttributes range:range];
    } else {
        NSMutableDictionary *dictionary = [[self.textView typingAttributes] mutableCopy];
        [dictionary setObject:[newAttributes valueForKey:styleAttributeName] forKey:styleAttributeName];
        [self.textView setTypingAttributes:dictionary];
    }
}

#pragma mark - formatter helpers

- (NSDictionary *)createActualAttributeStyle:(NSRange)inRange forTagName:(NSString *)tagName withText:(NSAttributedString *)attributedText
{
    UIFont *currentFont = [self fontAtIndex:inRange.location withinText:attributedText];
    NSDictionary* currentAttributes = @{};

    if ([tagName isEqualToString:@"b"]) {
        currentAttributes = [self createAttributesForFontStyle:currentFont
                                                     withTrait:UIFontDescriptorTraitBold];
    } else if ([tagName isEqualToString:@"i"]) {
        currentAttributes = [self createAttributesForFontStyle:currentFont
                                                     withTrait:UIFontDescriptorTraitItalic];
    } else if ([tagName isEqualToString:@"u"]) {
        currentAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                                        forKey:NSUnderlineStyleAttributeName];
    } else if ([tagName isEqualToString:@"s"]) {
        currentAttributes = @{ NSStrikethroughStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    }

    return currentAttributes;
}

- (NSDictionary*)createAttributesForFontStyle:(UIFont*)currentFont
                                    withTrait:(uint32_t)traitValue
{
    UIFontDescriptor *fontDescriptor = [currentFont fontDescriptor];

    if (!fontDescriptor) {
        fontDescriptor = [self.textView.richTextConfiguration.initialTextAttributes[NSFontAttributeName] fontDescriptor];
    }

    UIFontDescriptorSymbolicTraits existingTraitsWithNewTrait = [fontDescriptor symbolicTraits] | traitValue;

    UIFontDescriptor *descriptorWithTrait = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithNewTrait];

    UIFont* font =  [UIFont fontWithDescriptor:descriptorWithTrait size: 0.0];

    if (!font) {
        // in this case the default system font is found and can't set new
        // descriptors, so we use the textview initial one.
        font = self.textView.richTextConfiguration.initialTextAttributes[NSFontAttributeName];
    }

    return @{ NSFontAttributeName : font };
}

- (UIFont *)fontAtIndex:(NSInteger)index
{
    // If index at end of string, get attributes starting from previous character
    if (index == _backingStore.string.length && [self.textView hasText] && _backingStore.string.length > 0) {
        --index;
    }

    // If no text exists get font from typing attributes
    NSDictionary *dictionary = ([self.textView hasText] && index != _backingStore.string.length - 1)
    ? [_backingStore attributesAtIndex:index effectiveRange:nil]
    : self.textView.typingAttributes;

    return [dictionary objectForKey:NSFontAttributeName];
}

- (UIFont *)fontAtIndex:(NSInteger)index withinText:(NSAttributedString *)attributedText
{
    // If no text exists get font from typing attributes
    NSDictionary *dictionary = [attributedText attributesAtIndex:index effectiveRange:nil];

    return [dictionary objectForKey:NSFontAttributeName];
}

- (NSDictionary *)fontAttributesAtIndex:(NSInteger)index
{
    // If index at end of string, get attributes starting from previous character
    if (index == _backingStore.string.length && [self.textView hasText])
        --index;

    // If no text exists get font from typing attributes
    return  ([self.textView hasText])
    ? [_backingStore attributesAtIndex:index effectiveRange:nil]
    : self.textView.typingAttributes;
}

#pragma mark - output formatter tasks

- (NSString *)createOutputString
{
    return [self createOutputStringFromStore:_backingStore];
}

- (NSString *)createOutputStringFromStore:(NSMutableAttributedString *)backingStore
{
    NSMutableString *returnString = [NSMutableString string];

    [backingStore enumerateAttributesInRange:NSMakeRange(0, [backingStore.string length])
                            options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                         usingBlock:
        ^(NSDictionary *attributes, NSRange range, BOOL *stop)
    {
        NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        UIFontDescriptor *fontDescriptor = [[mutableAttributes objectForKey:NSFontAttributeName] fontDescriptor];
        UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;

        NSString *returnFontString = [backingStore.string substringWithRange:range];

        if (fontDescriptorSymbolicTraits & UIFontDescriptorTraitBold) {
            returnFontString = [NSString stringWithFormat:@"[b]%@[/b]", returnFontString];
        }

        if (fontDescriptorSymbolicTraits & UIFontDescriptorTraitItalic) {
            returnFontString = [NSString stringWithFormat:@"[i]%@[/i]", returnFontString];
        }

        if ([[attributes objectForKey:NSUnderlineStyleAttributeName] intValue] == 1) {
            returnFontString = [NSString stringWithFormat:@"[u]%@[/u]", returnFontString];
        }
        
        if ([[attributes objectForKey:NSStrikethroughStyleAttributeName] intValue] == 1) {
            returnFontString = [NSString stringWithFormat:@"[s]%@[/s]", returnFontString];
        }

        [returnString appendString:returnFontString];
    }];
    
    return returnString;
}

- (NSString *)createOutputString2
{
    NSMutableString *returnString = [NSMutableString string];
    __block NSDictionary *previousAttributes;
    
    [_backingStore enumerateAttributesInRange:NSMakeRange(0, [_backingStore.string length])
                                      options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                   usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop)
     {
         NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
         UIFontDescriptor *fontDescriptor = [[mutableAttributes objectForKey:NSFontAttributeName] fontDescriptor];
         UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;

         NSString *returnFontString = [_backingStore.string substringWithRange:range];

         UIFontDescriptorSymbolicTraits previousFontDescriptorSymbolicTraits = UIFontDescriptorClassUnknown;
         
         if (previousAttributes) {
             NSMutableDictionary *previousMutableAttributes = [NSMutableDictionary dictionaryWithDictionary:previousAttributes];
             UIFontDescriptor *previousFontDescriptor = [[previousMutableAttributes objectForKey:NSFontAttributeName] fontDescriptor];
             previousFontDescriptorSymbolicTraits = previousFontDescriptor.symbolicTraits;
             
             if (([[previousAttributes objectForKey:NSStrikethroughStyleAttributeName] intValue] == 1) &&
                 [[attributes objectForKey:NSStrikethroughStyleAttributeName] intValue] == 0) {
                 returnFontString = [NSString stringWithFormat:@"[/s]%@", returnFontString];
             }

             if (([[previousAttributes objectForKey:NSUnderlineStyleAttributeName] intValue] == 1) &&
                 [[attributes objectForKey:NSUnderlineStyleAttributeName] intValue] == 0) {
                 returnFontString = [NSString stringWithFormat:@"[/u]%@", returnFontString];
             }

             if ((previousFontDescriptorSymbolicTraits & UIFontDescriptorTraitItalic) &&
                 !(fontDescriptorSymbolicTraits & UIFontDescriptorTraitItalic)) {
                 returnFontString = [NSString stringWithFormat:@"[/i]%@", returnFontString];
             }
             
             if ((previousFontDescriptorSymbolicTraits & UIFontDescriptorTraitBold) &&
                 !(fontDescriptorSymbolicTraits & UIFontDescriptorTraitBold)) {
                 returnFontString = [NSString stringWithFormat:@"[/b]%@", returnFontString];
             }
         }
         
         if ((fontDescriptorSymbolicTraits & UIFontDescriptorTraitBold) &&
             !(previousFontDescriptorSymbolicTraits & UIFontDescriptorTraitBold)) {
             returnFontString = [NSString stringWithFormat:@"[b]%@", returnFontString];
         }
         
         if ((fontDescriptorSymbolicTraits & UIFontDescriptorTraitItalic) &&
             !(previousFontDescriptorSymbolicTraits & UIFontDescriptorTraitItalic)) {
             returnFontString = [NSString stringWithFormat:@"[i]%@", returnFontString];
         }
         
         if (([[attributes objectForKey:NSUnderlineStyleAttributeName] intValue] == 1) &&
             ([[previousAttributes objectForKey:NSUnderlineStyleAttributeName] intValue] == 0)) {
             returnFontString = [NSString stringWithFormat:@"[u]%@", returnFontString];
         }
         
         if (([[attributes objectForKey:NSStrikethroughStyleAttributeName] intValue] == 1) &&
             ([[previousAttributes objectForKey:NSStrikethroughStyleAttributeName] intValue] == 0)) {
             returnFontString = [NSString stringWithFormat:@"[s]%@", returnFontString];
         }

         previousAttributes = attributes;
         [returnString appendString:returnFontString];
     }];
    
    return returnString;
}

#pragma mark - common helper methods

- (NSRange)calculateMultilineRange:(NSRange)fromRange andTextString:(NSString *)textString
{
    NSRange extendedRange = NSUnionRange(fromRange,
                                         [textString lineRangeForRange:NSMakeRange(fromRange.location, 0)]);
    extendedRange = NSUnionRange(fromRange,
                                 [textString lineRangeForRange:NSMakeRange(NSMaxRange(fromRange), 0)]);
    return extendedRange;
}

@end
