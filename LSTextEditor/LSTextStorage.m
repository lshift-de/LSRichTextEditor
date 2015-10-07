//
//  LSTextStorage.m
//  LSTextEditor
//
//  Created by Peter Lieder on 14/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import "LSTextStorage.h"
#import "LSRichTextView.h"

@implementation LSTextStorage {
    NSMutableAttributedString *_backingStore;
    NSDictionary *_replacements;
}


- (instancetype)init
{
    if (self = [super init]) {
        _backingStore = [NSMutableAttributedString new];
    }
    return self;
}

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
    return [_backingStore attributesAtIndex:location
                             effectiveRange:range];
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
    
    [self processLinkDetectionInRange:range withString:str];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    NSLog(@"setAttributes:%@ range:%@", attrs, NSStringFromRange(range));
    
    [self beginEditing];
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

- (void)deleteAttributes:(NSDictionary *)attributes range:(NSRange)range
{
    NSLog(@"deleteAttributes:%@ range:%@", attributes, NSStringFromRange(range));
    
    [self beginEditing];

    for (NSString *attribute in attributes) {
        [_backingStore removeAttribute:attribute range:range];
    }

    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

- (void)processLinkDetectionInRange:(NSRange)range withString:(NSString *)str
{
    LSRichTextView *textView = (LSRichTextView *)self.delegate;

    // Regular expression matching all iWords -- first character i, followed by an uppercase alphabetic character, followed by at least one other character. Matches words like iPod, iPhone, etc.
    static NSDataDetector *linkDetector;
    linkDetector = linkDetector ?: [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:NULL];
    
    // Clear text color of edited range
    NSRange paragaphRange = [self.string paragraphRangeForRange: NSMakeRange(range.location, str.length)];
    [self removeAttribute:NSLinkAttributeName range:paragaphRange];
    [self removeAttribute:NSBackgroundColorAttributeName range:paragaphRange];
    [self removeAttribute:NSUnderlineStyleAttributeName range:paragaphRange];
    
    // Find all links in range
    [linkDetector enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self addAttribute:NSLinkAttributeName value:result.URL range:result.range];
        [self addAttribute:NSForegroundColorAttributeName value:textView.tintColor range:result.range];
        [self addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:result.range];
    }];
}

-(void)processEditing
{
    LSRichTextView *textView = (LSRichTextView *)self.delegate;

    if (textView.richTextConfiguration.configurationFeatures & ~LSRichTextFeaturesNone) {
        [self performReplacementsForRange:[self editedRange]];
    }

    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange
{
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string]
                                                        lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_backingStore string]
                                                lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    [self applyStylesToRange:extendedRange];
}

- (void)applyStylesToRange:(NSRange)searchRange
{
    [self createParserPatterns:searchRange];

    // iterate over each replacement
    for (NSString* key in _replacements) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:key
                                      options:0
                                      error:nil];
        
        NSDictionary* attributes = _replacements[key];
        NSMutableDictionary *tagReplacements = [[NSMutableDictionary alloc] init];

        if (NSMaxRange(searchRange) > self.length) {
            // adjusts the search range after string modification
            searchRange = NSMakeRange(searchRange.location, self.length);
        }
        
        [regex enumerateMatchesInString:[_backingStore mutableString]
                                options:0
                                  range:searchRange
                             usingBlock:^(NSTextCheckingResult *match,
                                          NSMatchingFlags flags,
                                          BOOL *stop) {
                                 // apply the style
                                 NSRange matchRange = [match rangeAtIndex:0];

                                 if (matchRange.location != NSNotFound && NSMaxRange(matchRange) <= self.length) {
                                     [self addAttributes:attributes range:matchRange];
                                 }

                                 NSRange matchSubRange = [match rangeAtIndex:1];
                                 if (matchSubRange.location != NSNotFound && NSMaxRange(matchSubRange) <= self.length) {
                                     NSString *targetSubString = [[_backingStore mutableString] substringWithRange:matchSubRange];
                                     [tagReplacements setValue:targetSubString forKey:NSStringFromRange(matchRange)];
                                 }
                             }];

        __block NSUInteger rangeOffset = 0;
        __block NSRange previousRange;

        [tagReplacements enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *sourceString = (NSString *)key;
            NSString *targetString = (NSString *)obj;
            
            NSRange range = NSRangeFromString(sourceString);
            
            if (previousRange.location != NSNotFound && previousRange.location < range.location) {
                // fixes the range changes during the string modification
                range = NSMakeRange(range.location - rangeOffset, range.length);
            }

            if (range.location != NSNotFound && NSMaxRange(range) <= self.length) {
                [self replaceCharactersInRange:range withString:targetString];
                rangeOffset += range.length - targetString.length;
                previousRange = range;
            }
        }];
    }
}


- (void) createParserPatterns:(NSRange)inRange {
    // TODO: should be moved into a formatter!
    
    UIFont *currentFont = [self fontAtIndex:inRange.location];

    // create the attributes
    NSDictionary* boldAttributes = [self createAttributesForFontStyle:currentFont
                                                            withTrait:UIFontDescriptorTraitBold];
    NSDictionary* italicAttributes = [self createAttributesForFontStyle:currentFont
                                                              withTrait:UIFontDescriptorTraitItalic];
    
    NSDictionary* strikeThroughAttributes = @{ NSStrikethroughStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSDictionary* underlineAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];

    // construct a dictionary of replacements based on regexes
    _replacements = @{
                      @"\\[b\\]((.|\n|\r)*)\\[/b\\]" : boldAttributes,
                      @"\\[i\\]((.|\n|\r)*)\\[/i\\]" : italicAttributes,
                      @"\\[u\\]((.|\n|\r)*)\\[/u\\]" : underlineAttributes,
                      @"\\[s\\]((.|\n|\r)*)\\[/s\\]" : strikeThroughAttributes};
}

- (NSDictionary*)createAttributesForFontStyle:(UIFont*)currentFont
                                    withTrait:(uint32_t)traitValue
{
    UIFontDescriptor *fontDescriptor = [currentFont fontDescriptor];
    UIFontDescriptorSymbolicTraits existingTraitsWithNewTrait = [fontDescriptor symbolicTraits] | traitValue;

    UIFontDescriptor *descriptorWithTrait = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithNewTrait];

    UIFont* font =  [UIFont fontWithDescriptor:descriptorWithTrait size: 0.0];
    return @{ NSFontAttributeName : font };
}

- (UIFont *)fontAtIndex:(NSInteger)index
{
    UITextView *textView = (UITextView *)self.delegate;

    // If index at end of string, get attributes starting from previous character
    if (index == _backingStore.string.length && [textView hasText]) {
        --index;
    }
    
    // If no text exists get font from typing attributes
    NSDictionary *dictionary = ([textView hasText])
        ? [_backingStore attributesAtIndex:index effectiveRange:nil]
        : textView.typingAttributes;
    
    return [dictionary objectForKey:NSFontAttributeName];
}

- (NSDictionary *)fontAttributesAtIndex:(NSInteger)index
{
    UITextView *textView = (UITextView *)self.delegate;

    // If index at end of string, get attributes starting from previous character
    if (index == _backingStore.string.length && [textView hasText])
        --index;
    
    // If no text exists get font from typing attributes
    return  ([textView hasText])
    ? [_backingStore attributesAtIndex:index effectiveRange:nil]
    : textView.typingAttributes;
}

- (void)applyTraitChangeToRange:(NSRange)range andTraitValue:(uint32_t)traitValue
{
    UITextView *textView = (UITextView *)self.delegate;

    UIFont *currentFont = [self fontAtIndex:range.location];
    UIFontDescriptor *fontDescriptor = [currentFont fontDescriptor];

    if (!fontDescriptor) {
        fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        NSLog(@"==============>>> preferredFontDescriptor is used!!!");
    }

    UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;
    BOOL isEnabled = (fontDescriptorSymbolicTraits & traitValue) != 0;

    UIFontDescriptor *changedFontDescriptor;
    
    NSLog(@"==> current font: %@, ENABLED STATE: %@", fontDescriptor, ((isEnabled)?@"YES":@"NO"));

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
        NSMutableDictionary *dictionary = [[textView typingAttributes] mutableCopy];
        [dictionary setObject:[changedAttributes valueForKey:NSFontAttributeName] forKey:NSFontAttributeName];
        [textView setTypingAttributes:dictionary];
    }
}

- (void)applyUnderlineChangeToRange:(NSRange)range andStyleAttributeName:(NSString *)styleAttributeName
{
    UITextView *textView = (UITextView *)self.delegate;

    NSDictionary *currentAttributesDict = (range.length > 0) ? [_backingStore attributesAtIndex:range.location effectiveRange:nil]
                                                             :  textView.typingAttributes;

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
        NSMutableDictionary *dictionary = [[textView typingAttributes] mutableCopy];
        [dictionary setObject:[newAttributes valueForKey:styleAttributeName] forKey:styleAttributeName];
        [textView setTypingAttributes:dictionary];
    }
}

#pragma output formatter tasks

- (NSString *)createOutputString
{
    NSMutableString *returnString = [NSMutableString string];

    [_backingStore enumerateAttributesInRange:NSMakeRange(0, [_backingStore.string length])
                            options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                         usingBlock:
        ^(NSDictionary *attributes, NSRange range, BOOL *stop)
    {
        NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        UIFontDescriptor *fontDescriptor = [[mutableAttributes objectForKey:NSFontAttributeName] fontDescriptor];
        UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;

        NSString *returnFontString = [_backingStore.string substringWithRange:range];

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

@end
