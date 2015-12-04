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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LSRichTextFeatures) {
    LSRichTextFeaturesNone          = 1 << 0,
    LSRichTextFeaturesPlainText     = 1 << 1,
    LSRichTextFeaturesReadonly      = 1 << 2,
    LSRichTextFeaturesBold          = 1 << 3,
    LSRichTextFeaturesItalic        = 1 << 4,
    LSRichTextFeaturesUnderlined    = 1 << 5,
    LSRichTextFeaturesStrikeThrough = 1 << 6,
    LSRichTextFeaturesAll           = 1 << 20
};

@interface LSRichTextConfiguration : NSObject

@property (nonatomic, assign) LSRichTextFeatures configurationFeatures;
@property (nonatomic, assign) NSTextCheckingType textCheckingTypes;
@property (nonatomic, strong) NSMutableDictionary *initialTextAttributes;
@property (nonatomic, weak) UIColor *defaultTextColor;
@property (nonatomic, weak) UIColor *highlightColor;

- (instancetype)initWithConfiguration:(LSRichTextFeatures)configurationFeatures;
- (void)setInitialAttributesFromTextView:(UITextView *)textView;

- (void)setTextCheckingType:(UIDataDetectorTypes)dataDetectorTypes;

@end
