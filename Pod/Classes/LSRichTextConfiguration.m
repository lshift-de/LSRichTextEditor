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
