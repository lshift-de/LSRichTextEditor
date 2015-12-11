//
//  LSRichTextConfiguration.m
//  LSTextEditor
//
//  Created by Peter Lieder on 22/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import "LSRichTextConfiguration.h"
#import "LSRichTextView.h"

@implementation LSRichTextConfiguration

- (instancetype)initWithTextFeatures:(LSRichTextFeatures)configurationFeatures
{
    if (self = [super init])
    {
        self.configurationFeatures = configurationFeatures;
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithTextFeatures:LSRichTextFeaturesNone];
}


- (void)setInitialAttributesFromTextView:(UITextView *)textView
{
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];

    if (textView.font) {
        [mutableAttributes setObject:textView.font forKey:NSFontAttributeName];
    }
    
    if (textView.textColor) {
        [mutableAttributes setObject:textView.textColor forKey:NSForegroundColorAttributeName];
    }
    
    if (textView.backgroundColor) {
        [mutableAttributes setObject:textView.backgroundColor forKey:NSBackgroundColorAttributeName];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = textView.textAlignment;

    [mutableAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    self.initialTextAttributes = mutableAttributes;
}

- (void)setTextCheckingType:(UIDataDetectorTypes)dataDetectorTypes;
{
    _textCheckingTypes = NSTextCheckingTypesFromUIDataDetectorTypes(dataDetectorTypes);
}

static inline NSTextCheckingType NSTextCheckingTypesFromUIDataDetectorTypes(UIDataDetectorTypes dataDetectorType) {
    NSTextCheckingType textCheckingType = 0;
    if (dataDetectorType & UIDataDetectorTypeAddress) {
        textCheckingType |= NSTextCheckingTypeAddress;
    }

    if (dataDetectorType & UIDataDetectorTypeCalendarEvent) {
        textCheckingType |= NSTextCheckingTypeDate;
    }

    if (dataDetectorType & UIDataDetectorTypeLink) {
        textCheckingType |= NSTextCheckingTypeLink;
    }

    if (dataDetectorType & UIDataDetectorTypePhoneNumber) {
        textCheckingType |= NSTextCheckingTypePhoneNumber;
    }

    return textCheckingType;
}

@end
